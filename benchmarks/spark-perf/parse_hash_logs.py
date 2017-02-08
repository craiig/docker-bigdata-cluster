#!/usr/bin/env python
import sys, re
import os
import csv

# invoke as:
# grep -P "Merged hash: .*" | ./this_script.py


# mllib_perf_output__2017-02-06_10-11-54_logs/decision-tree.err:17/02/06 10:24:34 INFO ClosureCleaner: Merged hash: bc:gGZVwKBJktN7fkm+2QMNMKaYHkrajdvITD5Gu6es6A8=_pr:qjVhacY/fwyVmdVuDNoyH3unoUlt+CTIi8raPhJxohM=
re_line = re.compile(".*?mllib_perf_output__(.*?)_logs/(.*?):(.*?) INFO ClosureCleaner: Merged Hash: bc:(.*?)_pr:(.*)", re.I)
columns = ["run_id", "benchmark", "timestamp", "bytecode hash", "primitive hash"]
csv = csv.DictWriter( sys.stdout, fieldnames= columns )
csv.writeheader()

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
        csv.writerow(obj)
    else:
        print >> sys.stderr, "error: could not parse line"
        print >> sys.stderr, l
        # sys.stdout.write("error: could not parse line")
        sys.exit(1)

