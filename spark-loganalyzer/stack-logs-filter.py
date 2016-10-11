#!/usr/bin/env python

# filter sample files based on task ID
# could extend this with arguments later

#typically used in a shell script, like:
# find samples/ -iname "*.hpl" | ../../stack-logs-filter.py 2313 | xargs -I{} cp {} samples_last/


import sys, re

def usage():
    print "%s <task_number>" % (sys.argv[0])
    print "returns all files that are greater or equal to given task number"

if len(sys.argv) < 2:
    usage()
    sys.exit()

file_pattern = re.compile("profile_.*task=(\d+)", re.IGNORECASE)
split_number = int(sys.argv[1])

for l in sys.stdin:
    m = file_pattern.search(l)
    if m:
        if int( m.group(1) ) >= split_number:
            print l,
