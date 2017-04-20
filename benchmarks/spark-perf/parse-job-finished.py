#!/usr/bin/env python
import sys, re
import os
import csv
import argparse

# grep -Pir "Job \d+ finished" *.err > debug-job-finished
test = "als.err:17/04/03 17:11:10 INFO DAGScheduler: Job 0 finished: count at MLAlgorithmTests.scala:360, took 3.654619 s"
re_took = re.compile('(.*?):.*?INFO.*?: Job (\d+) finished: (.*?), took ([\.\d]+) s$', re.I)

if( re_took.match(test) == None ):
    print "Error: did not even match test string"
    sys.exit(1)

columns = ["benchmark", "job", "name", "time"]
out = csv.DictWriter( sys.stdout, fieldnames= columns )
out.writeheader()

for l in sys.stdin:
    m = re_took.match(l)
    if m:
        o = {
            "benchmark": m.group(1)
            , "job": m.group(2)
            , "name": m.group(3)
            , "time": m.group(4)
            }
        out.writerow(o)
