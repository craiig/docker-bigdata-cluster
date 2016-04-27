/* calculates a breakdown for all benchmarks uploaded */

begin;

drop materialized view if exists interpreter_breakdown;
create materialized view interpreter_breakdown as
(
with sums as (
	select
	benchmark_id as bid,
	count(*) as count,
	case
		when array_to_string(stack_names, ',') ~* '.*CompileBroker::compiler_thread_loop.*' then 'compiler'
		when array_to_string(stack_names, ',') ~* '.*GCTaskThread::run.*' then 'java garbage collection'
		
		when stack_names[2]  ~* '.*/.*' and stack_names[1] ~* '.*interpreter.*'
			then 'jit -> interpreter'
		when stack_names[2] ~* '.*interpreter.*' and stack_names[1]  ~* '.*/.*' 
			then 'interpreter -> jit'
		when stack_names[2] ~* '.*/.*'  and stack_names[1]  ~* '.*/.*' 
			then 'jit -> jit'
		when stack_names[2] ~* '.*interpreter.*' and stack_names[1]  ~* '.*interpreter.*'
			then 'interpreter -> interpreter'

		/* if  none of the above match, assume we call the java process */
		when stack_names[2]  ~* '.*/.*'
			then 'jit -> java process'
		when stack_names[2] ~* '.*interpreter.*'
			then 'interpreter -> java process'
		
		when stack_mods[array_lower(stack_mods, 1)] ~* 'perf-*' then 'perf map (excludes java jit)'
		when process_name ~* '.*java.*' then 'java process (not jit or interpreted)'
		when process_name ~* '.*swapper.*' then 'swapper'
		else process_name
	end as breakdown
	
	from perf_stack_trace
	--where benchmark_id = 1 -- REMOVE THIS IN PROD
	group by
		benchmark_id, breakdown
	--limit 1000
)
select *
, (count::numeric / total_samples::numeric) as pct
from
sums, perf_profiles_facts as facts
where sums.bid = facts.benchmark_id
order by pct
);
end;
