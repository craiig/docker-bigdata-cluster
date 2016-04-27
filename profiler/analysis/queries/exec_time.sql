--- execution time duration
select
	case
		when name ~* '1a' then 'q1a'
		when name ~* '1b' then 'q1b'
		when name ~* '1c' then 'q1c'
		when name ~* '2a' then 'q2a'
		when name ~* '2b' then 'q2b'
		when name ~* '3a' then 'q3a'
	end as benchmark,
	round(duration_ns / 1e9::numeric,2) as duration_s

from
	perf_profiles_times ppt,
	perf_profiles pp
where 
	ppt.benchmark_id = pp.benchmark_id
order by benchmark
