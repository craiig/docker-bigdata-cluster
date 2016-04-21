/* calculates a breakdown for all benchmarks uploaded */

begin;

drop materialized view if exists highlevel_breakdowns;
create materialized view highlevel_breakdowns as
(
/* now try to summarize the stacks into compiler / etc / other */
with sums as (
	select
	benchmark_id as bid,
	count(*) as count,
	case
		when array_to_string(stack_names, ',') ~* '.*CompileBroker::compiler_thread_loop.*' then 'compiler'
		when array_to_string(stack_names, ',') ~* '.*GCTaskThread::run.*' then 'java garbage collection'
		when stack_names[array_lower(stack_names, 1)] ~* '.*interpreter.*' then 'java interpreter'
		when stack_names[array_lower(stack_names, 1)] ~* '.*/.*' then 'java jit code'
		when stack_mods[array_lower(stack_mods, 1)] ~* 'perf-*' then 'perf map (excludes java jit)'
		when process_name ~* '.*java.*' then 'java process (not jit or interpreted)'
		when process_name ~* '.*swapper.*' then 'swapper'
		else process_name
	end as breakdown
	
	from perf_stack_trace
	-- where benchmark_id = 1 -- REMOVE THIS IN PROD
	group by
		benchmark_id, breakdown
)
select *
, (count::numeric / total_samples::numeric) as pct
from
sums, perf_profiles_facts as facts
where sums.bid = facts.benchmark_id
order by pct
);
end;
