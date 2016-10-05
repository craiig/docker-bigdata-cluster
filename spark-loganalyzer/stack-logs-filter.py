#!/usr/bin/env python

# filter sample files based on task ID
# could extend this with arguments later


import sys, re

def usage():
    print "%s <task_number>"
    print "returns all files that are greater or equal to given task number"

file_pattern = re.compile("profile_.*task=(\d+)", re.IGNORECASE)
split_number = int(sys.argv[1])

for l in sys.stdin:
    m = file_pattern.search(l)
    if m:
        if int( m.group(1) ) >= split_number:
            print l,
