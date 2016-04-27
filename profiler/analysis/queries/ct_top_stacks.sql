-- lowlevel breakdown of the top of stacks
-- used to generate popular functions for ECEE 527 project report
drop table if exists ctquery;
create temporary table ctquery as
(select
	process_name as "process",
	top as "top most function",
--	uts.count as "samples",
	case
		when name ~* '1a' then 'q1a'
		when name ~* '1b' then 'q1b'
		when name ~* '1c' then 'q1c'
		when name ~* '2a' then 'q2a'
		when name ~* '2b' then 'q2b'
		when name ~* '3a' then 'q3a'
	end as benchmark,
	round(pct*100,2) as "val"
--	,		pp.*, uts.*
from
	unique_top_stacks uts,
	perf_profiles pp
where uts.benchmark_id = pp.benchmark_id
order by benchmark asc, "val" desc);


select * from crosstab('select "top most function", benchmark, val from ctquery order by 1'
,'select distinct benchmark from ctquery order by 1')
as
( 
	"top most function" text,
	"q1a" text,
	"q1b" text,
	"q1c" text,
	"q2a" text,
	"q2b" text,
	"q3a" text
	);

