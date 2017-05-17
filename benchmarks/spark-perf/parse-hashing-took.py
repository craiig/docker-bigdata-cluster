#!/usr/bin/env python
import sys, re
import os
import csv
import argparse

# grep -ir "Hashing took" *.err >
# als.err:17/03/30 11:23:51 INFO ClosureCleaner: Hashing took: 73 ms
re_took = re.compile('(.*?):.*?INFO.*?: Hashing took: (\d+) ms closure:(.*)$', re.I)

columns = ["benchmark", "hash_time", "closure"]
out = csv.DictWriter( sys.stdout, fieldnames= columns )
out.writeheader()

for l in sys.stdin:
    m = re_took.match(l)
    if m:
        o = {
            "benchmark": m.group(1)
            , "hash_time": m.group(2)
            , "closure": m.group(3)
            }
        out.writerow(o)
