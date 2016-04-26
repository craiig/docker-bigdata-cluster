#!/usr/bin/env python

# import psycopg2
# support pypy
try:
    import psycopg2
except ImportError:
    # Fall back to psycopg2cffi
    from psycopg2cffi import compat
    compat.register()
    import psycopg2

import argparse
from pprint import pprint
import sys
import re
import time

# 1. create new benchmark entry based on argument to --name
# 2. upload stack information based on information read via stdin


#perf script should be
# perf script -f comm,pid,tid,cpu,time,event,ip,sym,dso,trace

# parse arguments
parser = argparse.ArgumentParser(description='upload perf script output to a sql database')
parser.add_argument("--name", required=True)
parser.add_argument("--dbhost", default="localhost")
parser.add_argument("--dbname", default="postgres")
parser.add_argument("--dbuser", default="postgres")
parser.add_argument("--dbpass", required=True)
parser.add_argument("--dryrun", action='store_true', default=False)
parser.add_argument("--emit_benchmark_id", default=True)
opts = parser.parse_args()

#the queries needed
insert_query = """
insert into perf_profiles (name, cmdline, perfinfo)
VALUES (%(name)s, %(cmdline)s, %(perfinfo)s)
returning benchmark_id;
"""

stack_upload_query = """
insert into perf_stack_trace
(benchmark_id, pid, tid,
process_name, stack_time_ns, stack_addresses,
stack_names, stack_mods)
VALUES
(%(benchmark_id)s, %(pid)s, %(tid)s,
%(process_name)s, %(stack_time_ns)s, %(stack_addresses)s,
%(stack_names)s, %(stack_mods)s)
"""

buffer_upload_query = """
insert into perf_stack_trace
(benchmark_id, pid, tid,
process_name, stack_time_ns, stack_addresses,
stack_names, stack_mods)
VALUES
(%(benchmark_id)s, %(pid)s, %(tid)s,
%(process_name)s, %(stack_time_ns)s, %(stack_addresses)s,
%(stack_names)s, %(stack_mods)s)
"""

# start db connection
conn = psycopg2.connect(
   "host={dbhost} dbname={dbname} user={dbuser} password={dbpass}".format(
       **{
           "dbhost":opts.dbhost,
           "dbname":opts.dbname,
           "dbuser":opts.dbuser,
           "dbpass":opts.dbpass
       }))
cur = conn.cursor()

#variables for inserting into the benchmark entries
benchmark_id = None
cmdline = None
perfinfo = ""

#variables for inserting into the stacks
pid = None
tid = None
process_name = None
stack_time_ns = None
process_name = None
stack_addresses = list()
stack_names = list()
stack_mods = list()

#track some state for a lame parser
cur_state = "start"

#performance measurement
perf_start_time = None
perf_stop_time = None
perf_avg_list = list()
perf_samples = 1
perf_record_count = 0

def perf_start():
    global perf_start_time
    perf_start_time = time.clock()

def perf_stop():
    global perf_stop_time
    global perf_start_time
    perf_stop_time = time.clock()
    # print "start: %s stop: %s took: %s" % ( perf_start, perf_stop, perf_stop-perf_start)
    diff = perf_stop_time - perf_start_time
    print diff
    perf_avg_list.append(diff)
    if (len(perf_avg_list) >= perf_samples):
        print "%s average: %s" % (perf_samples, sum(perf_avg_list)/len(perf_avg_list))
        del perf_avg_list[:]

#2 read perf script from stdin
if cur_state == "start":
    for l in sys.stdin:
        m = re.match("^# ========", l)
        if m:
            cur_state = "header"
            break
else:
    print >> sys.stderr, "state trans failed"
    raise Exception("state trans failed")


#buffer for holding tuples we haven't uploaded yet
buffer_max = 10000 # number of records to hold
buffer = list()

if cur_state == "header":
    for l in sys.stdin:
        m = re.match("^# cmdline : (.*)", l)
        if m:
            cmdline =  m.group(1)

        m = re.match("^#", l)
        if m:
            perfinfo = perfinfo + l

        m = re.match("^# ========", l)
        if m:
            cur_state = "stacks"
            #1. new benchmark entry
            cur.execute(insert_query,
                    {
                        "name":opts.name,
                        "cmdline":cmdline,
                        "perfinfo":perfinfo
                    })
            benchmark_id = cur.fetchone()[0]
            print >> sys.stderr, "uploading scripts under bechmark_id %s" % (benchmark_id)
            break
else:
    print >> sys.stderr, "state trans failed"
    raise Exception("state trans failed")

re_match_pid = re.compile("^(\S+\s*?\S*?)\s+(\d+)\/(\d+).*?(\d+)\.(\d+)")
re_match_stack = re.compile("^\s*(\w+)\s*(.+) \((\S*)\)")
re_match_end = re.compile("^$")

perf_start()
if cur_state == "stacks":
    for l in sys.stdin:
        # m = re.match("^(\S+\s*?\S*?)\s+(\d+)\/(\d+).*?(\d+)\.(\d+)", l)
        m = re_match_pid.match(l)
        if m:
            process_name = m.group(1)
            pid = m.group(2)
            tid = m.group(3)
            stack_time_ns = int(m.group(4)) * 1e9 + int(m.group(5))

        # m = re.match("^\s*(\w+)\s*(.+) \((\S*)\)", l)
        m = re_match_stack.match(l)
        if m:
            (pc, func, mod) = m.groups()

            #for now store pc's as text
            pc = int(pc, 16)
            stack_addresses.append(pc)
            stack_names.append(func)
            stack_mods.append(mod)

        # m = re.match("^$", l)
        m = re_match_end.match(l)
        if m:
            #end of stack
            stackframe ={
            "benchmark_id": benchmark_id,
            "pid": pid, 
            "tid": tid, 
            "process_name": process_name, 
            "stack_time_ns": stack_time_ns, 
            "process_name": process_name, 
            "stack_addresses": stack_addresses, 
            "stack_names": stack_names, 
            "stack_mods": stack_mods, 
            }
            perf_record_count = perf_record_count + 1
            # pprint(stackframe)
            # print cur.mogrify(stack_upload_query, stackframe)
            # sys.exit()
            # if opts.dryrun == False:
            buffer.append(stackframe)
            if len(buffer) >= buffer_max:
                cur.executemany(buffer_upload_query, buffer)
                print >>sys.stderr, "uploaded"
                del buffer[:]
                perf_stop()
                perf_start()

            pid = None
            tid = None
            process_name = None
            stack_time_ns = None
            process_name = None
            stack_addresses = list()
            stack_names = list()
            stack_mods = list()
else:
    print >> sys.stderr, "state trans failed"
    raise Exception("state trans failed")

#finish up final batch
if len(buffer) >= 0:
    cur.executemany(buffer_upload_query, buffer)
    print >>sys.stderr, "uploaded final"
    del buffer[:]

if opts.dryrun:
    print >> sys.stderr, "rolling transaction back due to dry run"
    print >> sys.stderr, "records read: %s" % (perf_record_count)
    conn.rollback()
else:
    conn.commit()
#cur.execute("CLUSTER perf_stack_trace") #recluster data

if opts.emit_benchmark_id:
    print benchmark_id
