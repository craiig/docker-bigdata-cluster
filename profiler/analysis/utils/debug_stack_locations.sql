
select
*
from
	perf_stack_trace
where
	-- stack_names[array_lower(stack_names, 1)] ~* '.*/.*'
	stack_names[array_lower(stack_names, 1)] ~* '.*unknown.*'
limit 2;
