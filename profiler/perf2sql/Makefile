LIBS := -lpqxx -lboost_regex -lboost_program_options

all: perf2sql-dbg perf2sql perf2sql-gprof

#command line to install some dependent libraries
install-apt:
	sudo apt-get install libboost-regex-dev 

test: perf2sql
	./$^ --dbpass 123 < ../perf_script_test

perf2sql: perf2sql.cpp
	g++-4.9 -std=gnu++14 -g3 -O3 -flto -o $@  $< $(LIBS)

perf2sql-gprof: perf2sql.cpp
	g++-4.9 -std=gnu++14 -g3 -O3 -pg -flto -o $@  $< $(LIBS)

perf2sql-dbg: perf2sql.cpp
	g++-4.9 -std=gnu++14 -g3 -O0 -o $@  $< $(LIBS)

clean:
	-rm perf2sql
	-rm perf2sql-dbg
	-rm perf2ql-gprof
