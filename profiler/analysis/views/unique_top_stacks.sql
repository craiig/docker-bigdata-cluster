/*
calculates all tops of each stack that are over 1% of the execution time
for most cases there aren't many - 
*/
begin;

drop materialized view if exists unique_top_stacks;
create materialized view unique_top_stacks as (

	with sums as 
	(
		select
			benchmark_id bid,
			process_name,
			pid,
			count(*) as count,
			array_agg(distinct floor(stack_addresses[array_lower(stack_addresses, 1)] / 8)) as stack_address,
			stack_names[array_lower(stack_names, 1)] as top
			
		from perf_stack_trace
		-- where perf_stack_trace.benchmark_id = 2 -- could remove this
		group by 
			benchmark_id,
			process_name,
			pid,
			stack_names[array_lower(stack_names, 1)]
			
		order by count desc
		limit 100
	)
	select *
	, (count::numeric / total_samples::numeric) as pct
	from
	sums, perf_profiles_facts as facts
	where sums.bid = facts.benchmark_id
	and (count::numeric / total_samples::numeric) > 0.01

);

end;
