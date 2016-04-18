BEGIN;

DROP TABLE IF EXISTS "public"."perf_profiles" CASCADE;
CREATE TABLE "public"."perf_profiles" (
	"benchmark_id" serial PRIMARY KEY,
	"name" text,
	"time" timestamp default CURRENT_TIMESTAMP,
	"cmdline" text,
	"perfinfo" text
);


DROP TABLE IF EXISTS "public"."perf_stack_trace" CASCADE;
CREATE TABLE "public"."perf_stack_trace" (
	    "benchmark_id" integer references "perf_profiles",
	    "stack_id" serial PRIMARY KEY,
	    "pid" integer,
	    "tid" integer,
	    "process_name" text,
	    "stack_time_ns" bigint, /* this should be able to hold years of runtime */
	    "stack_addresses" numeric[],
	    "stack_names" text[],
	    "stack_mods" text[]
);
CREATE INDEX "benchmark_idx" ON "perf_stack_trace"("benchmark_id");
ALTER TABLE "perf_stack_trace" CLUSTER ON "benchmark_idx";

--ROLLBACK;
END;
