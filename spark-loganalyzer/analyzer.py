#!/usr/bin/env python

import argparse
from pprint import pprint
from collections import OrderedDict as odict
import os,sys
import re
import json
from human2bytes import human2bytes

parser = argparse.ArgumentParser(description='parse spark logs and collect important stats')
parser.add_argument("--events", "-e", nargs="*")
parser.add_argument("--executors", "-x", nargs="*")
parser.add_argument("--driver", "-d", nargs="*")

args = parser.parse_args()

def check_file(file):
    if not os.path.exists(file):
        raise Exception("{path} does not exist".format(path=file))

def get_executor_id(log):
    #increase this if you have problems finding the executor id in the first 1000 lines
    check_limit = 1000
    with open(log) as f:
        count = 0
        for l in f:
            m = re.search("INFO executor.Executor: Starting executor ID (\d) on host ([\d\.]*)", l, flags=re.IGNORECASE)
            if m:
                return (m.group(1), m.group(2))
            count += 1
            if count > check_limit:
                break
    return None

def parse_executor_stats(log):
    stats = odict()
    stats['MemoryStore.events'] = []
    # stats['MemoryStore.all_blocks'] = []
    stats['MemoryStore.max_occupancy'] = 0
    stats['partition_misses'] = 0
    stats['partition_not_stored'] = 0
    stats['partition_hits'] = 0
    stats['partition_hits_local'] = 0
    stats['partition_hits_remote'] = 0
    stats['tasks_run'] = 0
    with open(log) as f:
        for l in f:
            try:
                m = re.search("INFO storage.MemoryStore: MemoryStore started with capacity (.*)$", l, flags=re.IGNORECASE)
                if m:
                    stats['MemoryStore.capacity'] = m.group(1)

                # note: there is a bug in the spark logging, where 'free' is actually current occupancy
                # see storage/MemoryStore.scala
                m = re.search("INFO storage.MemoryStore: Block (.*) stored as (.*) in memory \(estimated size (.*), free (.*)\)", l, flags=re.IGNORECASE)
                if m:
                    bytes = human2bytes(m.group(4))
                    stats['MemoryStore.max_occupancy'] = max(bytes, stats['MemoryStore.max_occupancy'])
                    stats['MemoryStore.final_occupancy'] = m.group(4)
                    # stats['MemoryStore.all_blocks'].append( m.group(1) )

                #another way to see memorystore occupancy
                m = re.search("INFO storage.MemoryStore: Memory use = (.*) \(blocks\) \+ (.*) \(scratch space shared across (.*) tasks\(s\)\) = (.*)\. Storage limit = (.*)", l, flags=re.IGNORECASE)
                if m:
                    bytes = human2bytes(m.group(4))
                    stats['MemoryStore.max_occupancy'] = max(bytes, stats['MemoryStore.max_occupancy'])
                    stats['MemoryStore.final_occupancy'] = m.group(4)

                m = re.search("INFO spark.CacheManager: Partition (.*) not found, computing it", l, flags=re.IGNORECASE)
                if m:
                    stats['partition_misses'] += 1

                m = re.search("INFO storage.MemoryStore: Will not store (.*) as it would require dropping another block from the same RDD", l, flags=re.IGNORECASE)
                if m:
                    stats['partition_not_stored'] += 1

                m = re.search("INFO storage.BlockManager: Found block (.*) (.*)", l, flags=re.IGNORECASE)
                if m:
                    stats['partition_hits'] += 1
                    if m.group(2) == 'locally':
                        stats['partition_hits_local'] += 1
                    elif m.group(2) == 'remotely':
                        stats['partition_hits_remote'] += 1

                m = re.search("INFO executor.Executor: Finished task (.*) in stage (.*) \(TID (.*)\)", l, flags=re.IGNORECASE)
                if m:
                    stats['tasks_run'] += 1
            except Exception as e:
                print l
                raise

    return stats

def get_executor_stats(logs):
    ret = []
    for l in logs:
        eid = get_executor_id(l)
        if eid == None:
            print >>sys.stderr, "Warning: {log} is not a valid executor log".format(log=l)
            continue

        stats = parse_executor_stats(l)
        ret.append( (eid, stats) )
    return ret

def is_valid_event_log(log):
    #increase this if you have problems finding the event log start 
    check_limit = 1
    with open(log) as f:
        count = 0
        for l in f:
            j = json.loads(l)
            if j['Event'] == 'SparkListenerLogStart':
                return True

            count += 1
            if count > check_limit:
                break

    return False

def parse_event_stats(log):

    stats = odict()
    stats['event_counts'] = {}
    stats['stage_stats'] = odict()

    def get_stage_stats(stageid):
        if stageid not in stats['stage_stats']:
            nstats = odict()
            nstats['metric_totals'] = {}
            stats['stage_stats'][stageid] = nstats

        return stats['stage_stats'][stageid]

    with open(log) as f:
        for l in f:
            try:
                j = json.loads(l)
                event = j['Event']
                stats['event_counts'][event] = stats['event_counts'].get(event,0) + 1

                if event == 'SparkListenerTaskEnd':
                    s = get_stage_stats( j['Stage ID'] )
                    metrics_capture = [
                            'Executor Deserialize Time',
                            'Executor Run Time',
                            'Result Serialization Time',
                            'JVM GC Time',
                    ]

                    metrics = j['Task Metrics']
                    totals = s['metric_totals']
                    for e in metrics_capture:
                        totals[e] = totals.get(e, 0) + metrics[e]

            except Exception as e:
                print l
                raise

    return stats

def get_event_stats(logs):
    ret = []
    for l in logs:
    	if not is_valid_event_log(l):
            print >>sys.stderr, "Warning: {log} is not a valid event log".format(log=l)
            continue

        ret.append(parse_event_stats(l))

    return ret

#main driver
if args.driver:
    [check_file(l) for l in args.driver]
if args.executors:
    [check_file(l) for l in args.executors]
if args.events:
    [check_file(l) for l in args.events]

if args.executors:
    print args.executors
    exec_stats = get_executor_stats(args.executors)
    print "Executor Stats:"
    print(json.dumps(exec_stats, indent=4))
else:
    exec_stats = None

if args.events:
    event_stats = get_event_stats(args.events)
    print "Event Log Stats:"
    print(json.dumps(event_stats, indent=4))
