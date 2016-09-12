#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
	echo "usage $0 <application_id>"
	exit 1
fi
$DIR/grab-logs-docker.sh $1
$DIR/grab-event-logs-hdfs.sh $1
