#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo "usage $0 <application_id>"
	exit 1
fi

hdfs dfs -get /spark_event_logs/$1 ./
