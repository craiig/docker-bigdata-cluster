#!/usr/bin/env bash
set -e
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/spark-perf
$DIR/clear-spark-logs.sh
bin/run | tee debug-run-tests-revival

