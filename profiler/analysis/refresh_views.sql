-- begin;
-- refresh materialized view interpreter_breakdown;
-- end;
-- begin;
-- refresh materialized view perf_profiles_facts;
-- end;
-- begin;
-- refresh materialized view perf_profiles_times;
-- end;
begin;
refresh materialized view unique_top_stacks; --failed due to lack of space, needs refresh
end;
-- begin;
-- refresh materialized view highlevel_breakdowns;
-- end;
