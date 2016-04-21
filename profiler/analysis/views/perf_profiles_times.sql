begin;
drop materialized view if exists perf_profiles_times;
create materialized view perf_profiles_times as
(
	select 
		benchmark_id,
		count(*) as total_samples,
		min(stack_time_ns) as min_time_ns,
		max(stack_time_ns) as max_time_ns,
		max(stack_time_ns) - min(stack_time_ns) as duration_ns
	from perf_stack_trace
	group by benchmark_id
);
end;
