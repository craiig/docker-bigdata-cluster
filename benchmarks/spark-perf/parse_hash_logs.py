#!/usr/bin/env python
import sys, re
import os
import csv
import argparse

# invoke as:
# grep -P "Merged hash: .*" | ./this_script.py --type TYPE

parser = argparse.ArgumentParser(description='parse some debug output from modified spark')
parser.add_argument('--type', required=True, default='merged_hash')

def merged_hash():
    # mllib_perf_output__2017-02-06_10-11-54_logs/decision-tree.err:17/02/06 10:24:34 INFO ClosureCleaner: Merged hash: bc:gGZVwKBJktN7fkm+2QMNMKaYHkrajdvITD5Gu6es6A8=_pr:qjVhacY/fwyVmdVuDNoyH3unoUlt+CTIi8raPhJxohM=
    re_line = re.compile(".*?mllib_perf_output__(.*?)_logs/(.*?):(.*?) INFO ClosureCleaner: Merged Hash: bc:(.*?)_pr:(.*)", re.I)
    columns = ["run_id", "benchmark", "timestamp", "bytecode hash", "primitive hash"]
    out = csv.DictWriter( sys.stdout, fieldnames= columns )
    out.writeheader()

    for l in sys.stdin:
        m = re_line.match(l)
        if m:
            # print l
            # print m.groups()
            obj = {
                "run_id": m.group(1),
                "benchmark": m.group(2),
                "timestamp": m.group(3),
                "bytecode hash": m.group(4),
                "primitive hash": m.group(5),
            }
            out.writerow(obj)
        else:
            print >> sys.stderr, "error: could not parse line"
            print >> sys.stderr, l
            # sys.stdout.write("error: could not parse line")
            sys.exit(1)


def rdd_hash():
    # word2vec-logs/container_1486404651441_1079_01_000002/stderr:17/02/26 23:46:10 INFO storage.MemoryStore: Cached block rdd_11_1 hash: CJ8PgrM/foyvsNKIdESrfuKiOoNDGNpDcuJrSYfj17w= size: 4027
    re_line = re.compile("^([^\./]*).*?:.*? INFO (storage\.)?MemoryStore: Cached block (.*?) hash: (.*?) size: (.*?)$", re.I)
    columns = ["benchmark", "rdd_name", "rdd_hash", "rdd_size"]
    out = csv.DictWriter( sys.stdout, fieldnames= columns )
    out.writeheader()

    for l in sys.stdin:
        m = re_line.match(l)
        if m:
            # print l
            # print m.groups()
            obj = {
                "benchmark": m.group(1),
                "rdd_name": m.group(3),
                "rdd_hash": m.group(4),
                "rdd_size": m.group(5),
            }
            out.writerow(obj)
        else:
            print >> sys.stderr, "error: could not parse line"
            print >> sys.stderr, l
            # sys.stdout.write("error: could not parse line")
            sys.exit(1)

#main
types = {
        'merged_hash': merged_hash
        , 'rdd_hash': rdd_hash
        }

args = parser.parse_args()
if args.type not in types.keys():
    print >> sys.stderr, "error, log type %s not valid" % args.type
    print >> sys.stderr, "valid types: %s " % (types.keys())
    sys.exit(1)

#invoke chosen parser
types[args.type]()
