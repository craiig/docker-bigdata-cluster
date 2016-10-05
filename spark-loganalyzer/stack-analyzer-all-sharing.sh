#!/usr/bin/env bash

# output new analysis for all files
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat $DIR/logs/accumulo_primary_twice/first.log | ../../stack-analyzer.py -n "Accumulo Baseline" -s
echo
cat $DIR/logs/accumulo_primary_twice/second.log | ../../stack-analyzer.py -n "Accumulo Local Cache" -s
echo
cat $DIR/logs/accumulo_secondary/allstacks.log | ../../stack-analyzer.py -n "Accumulo Remote Cache" -s
echo
cat $DIR/logs/hdfs_primary_twice/first.log | ../../stack-analyzer.py -n "HDFS Baseline" -s
echo
cat $DIR/logs/hdfs_primary_twice/second.log | ../../stack-analyzer.py -n "HDFS Local Cache" -s
echo
cat $DIR/logs/hdfs_secondary_once/first.log | ../../stack-analyzer.py -n "HDFS Remote Cache" -s
echo
