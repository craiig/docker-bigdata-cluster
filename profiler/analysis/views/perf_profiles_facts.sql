begin;
drop materialized view if exists perf_profiles_facts;
create materialized view perf_profiles_facts as
(
	select 
		benchmark_id,
		count(*) as total_samples
	from perf_stack_trace
	group by benchmark_id
);
end;
