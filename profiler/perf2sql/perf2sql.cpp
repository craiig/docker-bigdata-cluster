
/*
 * mirrors the python version but is hopefully much faster
 */

#include <stdio.h>
#include <iostream>
#include <string>
#include <cassert>
#include <queue>

#include <sys/time.h> //gettimeofday

#include <boost/program_options.hpp>
namespace po = boost::program_options;

using namespace std;

#include <pqxx/pqxx>
//using namespace pqxx;

//#ifdef __llvm__
//#include <tr1/regex>
//using namespace std::tr1;
//#else
//#include <regex>
#include <boost/regex.hpp>
using namespace boost;
//#endif

//per item profiling
//#define PROFILE

#define USE_PIPELINE

int insert_benchmark(
		pqxx::work& trans,
		const string& name,
		const string& cmdline,
		const string& perfinfo){

	std::stringstream q;
	q << 
		"insert into perf_profiles (name, cmdline, perfinfo) VALUES ("
		<< trans.quote(name) << ", "
		<< trans.quote(cmdline) << ", "
		<< trans.quote(perfinfo) 
		<< ") returning benchmark_id;";
	auto r = trans.exec(q);
	int bid = r[0][0].as<int>();
	return bid;
}

//some rate limiting so we don't exhaust memory
//todo: tune this better, this gave 21minutes
const int max_query_buffer = 10000; //how many queries to submit to the pipeline
const int pipe_drain_num = 1000; //how much do we drain the pipeline by
const int pipeline_retain = 1000; //how much does libpqxx retain before submitting to the backend
int num_active_queries = 0; //count outstanding queries

void insert_stack(
#ifdef USE_PIPELINE
		pqxx::pipeline& pipe,
#endif
		pqxx::work& trans,
		//#variables for inserting into the benchmark entries
		const int benchmark_id,
		//#variables for inserting into the stacks
		const string& pid,
		const string& tid,
		const string& process_name,
		const unsigned long int stack_time_ns,
		const vector<unsigned long int>& stack_addresses,
		const vector<string>& stack_names,
		const vector<string>& stack_mods
	){
	//std::stringstream* q = new std::stringstream();
	//(*q)
	std::stringstream q;
	q	
		<< "insert into perf_stack_trace"
		"(benchmark_id, pid, tid,"
		"process_name, stack_time_ns, stack_addresses,"
		"stack_names, stack_mods)"
		"VALUES ("
			<< benchmark_id << "," << pid << "," << tid << ","
			<< trans.quote(process_name) << "," << stack_time_ns << ","
			<< "'{" << pqxx::separated_list(",", stack_addresses) << "}',"
			<< "'{" << pqxx::separated_list(",", stack_names) << "}',"
			<< "'{" << pqxx::separated_list(",", stack_mods) << "}'"
		<< ");";
	pipe.insert(q.str());

	num_active_queries++;
	if(num_active_queries > max_query_buffer){
		for(int i=0; i<pipe_drain_num; i++){
			pipe.retrieve();
			num_active_queries--;
		}
	}
}

int main(int argc, char* argv[]){

	string benchmark_name;
	string dbhost = "127.0.0.1";
	string dbname = "postgres";
	string dbuser = "postgres";
	string dbpass;
	bool dryrun = false;
	bool timing_output = true;

	po::options_description desc("perf2sql uploads perf script output to a sql database");
	desc.add_options()
		("help", "produce help message")
		("name", po::value<string>(&benchmark_name), "benchmark name")
		("dbhost", po::value<string>(&dbhost), "database host")
		("dbuser", po::value<string>(&dbuser), "database user")
		("dbname", po::value<string>(&dbname), "database name")
		("dbpass", po::value<string>(&dbpass), "database pass")
		("dryrun", po::bool_switch(&dryrun), "dry run")
		("timing-output", po::bool_switch(&timing_output), "output timing info");
	po::variables_map vm;
	po::store(po::parse_command_line(argc, argv, desc), vm);
	po::notify(vm);

	if(benchmark_name.length() == 0){
		cerr << "Please provide --name" << endl;
		cerr << desc;
		return 1;
	}
	if(dbpass.length() == 0){
		cerr << "Please provide --dbpass" << endl;
		cerr << desc;
		return 1;
	}

	if(dryrun){
		cerr << "Dry run" << endl;
	}

#ifdef PROFILE
	struct timeval perf_start;
	struct timeval perf_stop;
#endif

	/* check database connection early */
	std::string connstr = "dbname=" + dbname + " host= " + dbhost
		+ " user="+dbuser + " password="+dbpass;
	pqxx::connection conn(connstr);
	pqxx::work trans(conn); //basic transaction

	/* file input and parser state */
	FILE* fh = stdin;
	enum {
		start,
		header,
		stacks
	} cur_state = start;	

	//#variables for inserting into the benchmark entries
	int benchmark_id;
	string cmdline;
	string perfinfo;

	//#variables for inserting into the stacks
	string pid;
	string tid;
	string process_name;
	unsigned long int stack_time_ns = 0; assert(sizeof(stack_time_ns) == 8);
	vector<unsigned long int> stack_addresses;
	vector<string> stack_names;
	vector<string> stack_mods;

	//variables for tracking status
	const int status_report_interval = 10000; //report every N records
	int status_record_count = 0;
	struct timeval status_begin;
	struct timeval status_end;
	gettimeofday(&status_begin, NULL);

	// variables for parsing
	string l;
	smatch cm;
	bool m; 
#define re_match(res, cm, pat, str) {\
	regex reg (pat); \
	res = regex_match(str, cm, reg); }
	if( cur_state == start ){
		while(!std::cin.eof() && std::getline( std::cin, l) ){
			re_match(m, cm, "^# ========", l);
			if( m ){
				cur_state = header;
				/*cout << "header matched: " << l << endl;*/
				break;
			}
		}
	} else {
		fprintf(stderr, "state trans failed cur_state: %d, expected:%d\n", cur_state, start);
		return 1;
	}

	if( cur_state == header ){
		while(!std::cin.eof() && std::getline( std::cin, l) ){
			re_match(m, cm, "^# cmdline : (.*)", l);
			if( m ){
				/*cout << "cmdline matched: " << l << endl;*/
				cmdline =  cm[1];
			}

			re_match(m, cm, "^#.*", l);
			if( m ){
				/*cout << "matched other: " << l << endl;*/
				perfinfo = perfinfo + l;
			}

			re_match(m, cm, "^# ========", l);
			if( m ){
				/*cout << "matched: " << l << endl;*/
				cur_state = stacks;
				//1. new benchmark entry
				benchmark_id = insert_benchmark(
						trans,
						benchmark_name,
						cmdline,
						perfinfo
					);
				cerr << "benchmark_id: " << benchmark_id << endl;
				break;
			}
		}
	} else {
		fprintf(stderr, "state trans failed cur_state: %d, expected:%d\n", cur_state, header);
		return 1;
	}

	//setup a pipeline for the bulk inserts
	pqxx::pipeline pipe(trans, "perf_stack_traces");
	pipe.retain( pipeline_retain ); //hold a moderate amount of queries
	/* one difference between c++ regex is that match() has to match the 
	 * entire word, whereas python it just has to match the start
	 * */
	regex re_match_pid("^(\\S+\\s*?\\S*?)\\s+(\\d+)\\/(\\d+).*?(\\d+)\\.(\\d+).*");
	regex re_match_stack("^\\s*(\\w+)\\s*(.+) \\((\\S*)\\).*");
	regex re_match_end("^$");
	smatch sm;

#ifdef PROFILE
	gettimeofday(&perf_start, NULL);
#endif

	if( cur_state == stacks ){
		while(!std::cin.eof() && std::getline( std::cin, l) ){
			m = regex_match(l, sm, re_match_pid);
			if( m ){
				process_name = sm[1];
				pid = sm[2];
				tid = sm[3];
				auto stack_time_top = sm[4];
				auto stack_time_bot = sm[5];
				stack_time_ns = stoul(stack_time_top, NULL, 10) * 1e9 + stoul(stack_time_bot);

				/*cout << "matched: " << l << endl;*/
				/*cout << "process_name: " << process_name << endl;*/
				/*cout << "pid: " << pid << endl;*/
				/*cout << "tid: " << tid << endl;*/
				/*cout << stack_time_top << " * 1e9 + " << stack_time_bot << "= " << stack_time_ns << endl;*/
			}

			m = regex_match(l, sm, re_match_stack);
			if( m ){
				string spc = sm[1];
				string func = sm[2];
				string mod = sm[3];

				//for now store pc's as text
				unsigned long int pc = stoul(spc, NULL, 16);
				stack_addresses.push_back(pc);
				stack_names.push_back(func);
				stack_mods.push_back(mod);

				/*cout << "matched: " << l << endl;*/
				/*cout << "spc: " << spc << endl;*/
				/*cout << "pc: " << pc << endl;*/
				/*cout << "func: " << func << endl;*/
				/*cout << "mod: " << mod << endl;*/
			}

			m = regex_match(l, sm, re_match_end);
			if( m ){
				//end of stack
				insert_stack(
					#ifdef USE_PIPELINE
					pipe,
					#endif
					trans,
					benchmark_id,
					pid, 
					tid, 
					process_name, 
					stack_time_ns, 
					stack_addresses, 
					stack_names, 
					stack_mods
				);
				stack_addresses.clear();
				stack_names.clear();
				stack_mods.clear();

				if(timing_output){
					status_record_count++;
					if(status_record_count >= status_report_interval){
						gettimeofday(&status_end, NULL);
						unsigned long took =
							1e6 * (status_end.tv_sec - status_begin.tv_sec)
							+ (status_end.tv_usec - status_begin.tv_usec);
						cerr << "parsed " << status_record_count << " records";
						cerr << " in " <<  took << " microseconds" << endl;
						gettimeofday(&status_begin, NULL);
						status_record_count = 0;
					}
				}
#ifdef PROFILE
				gettimeofday(&perf_stop, NULL);
				unsigned long took = 1e6 * (perf_stop.tv_sec - perf_start.tv_sec) + (perf_stop.tv_usec - perf_start.tv_usec);
				printf("record took: %lu\n", took);
				gettimeofday(&perf_start, NULL);
#endif
			}
		}
	} else {
		fprintf(stderr, "state trans failed cur_state: %d, expected:%d\n", cur_state, stacks);
		return 1;
	}

	//finish result by flushing the pipe completely
	pipe.complete();

	//commit or don't
	if(dryrun){
		cout << "Aborting transaction because dry-run" << endl;
		trans.abort();
	} else {
		//cout << "Aborting transaction because debugging" << endl;
		//trans.abort();
		trans.commit();
	}
	//only output benchmark id to stdout on success, assume 
	//if we got here that we had success
	cout << benchmark_id << endl;
}
