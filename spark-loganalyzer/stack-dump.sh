#!/bin/bash

trap "exit" SIGHUP SIGINT SIGTERM

#usage: iterate over all files on the command line and dump stacks for each
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for e in "$@"; do
	$DIR/../java-profiler/console -format trace_line -log $e
done
