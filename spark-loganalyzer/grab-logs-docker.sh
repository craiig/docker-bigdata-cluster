#!/usr/bin/env bash
set -x
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "usage $0 <application_id> <docker_id>"
	exit 1
fi

#docker exec 9df99d6da55f bash -c "tar -c /usr/local/hadoop/logs/userlogs/application_1472514496790_0002/*" | tar -x -C ./ --strip-components=6 -k

docker exec $2 bash -c "tar -c /usr/local/hadoop/logs/userlogs/$1/*" | tar -x -C ./ --strip-components=6 -k
