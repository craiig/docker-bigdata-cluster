-- crosstab foramtted for high level breakdown
-- used to generate ECEE 527 project table

---
-- high level breakdown
drop table if exists ctquery;
create temporary table ctquery as
(
select
case
		when name ~* '1a' then 'q1a'
		when name ~* '1b' then 'q1b'
		when name ~* '1c' then 'q1c'
		when name ~* '2a' then 'q2a'
		when name ~* '2b' then 'q2b'
		when name ~* '3a' then 'q3a'
	end as benchmark,
	breakdown,
	round(pct*100,2) as "val"
	--, hlbd.*
from
	highlevel_breakdowns hlbd,
	perf_profiles pp
where pp.benchmark_id = hlbd.benchmark_id
and hlbd.pct>0.01
order by benchmark asc, "val" desc);

select * from crosstab('select "breakdown", benchmark, val from ctquery order by 1'
,'select distinct benchmark from ctquery order by 1')
as
( 
	"breakdown" text,
	"q1a" text,
	"q1b" text,
	"q1c" text,
	"q2a" text,
	"q2b" text,
	"q3a" text
	);
