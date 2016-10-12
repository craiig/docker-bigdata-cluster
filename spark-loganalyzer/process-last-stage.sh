#!/usr/bin/env bash
set -e
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
	echo "usage $0 <shell.log>"
	exit 1
fi

#to be run after all logs etc are grabbed

#find last stage and all tasks in it
stage=$(grep -Po "stage \d+" shell.log | tail -1)
tids=$( grep -i "finished.*$stage.*TID" shell.log | grep -Po "(?<=TID )\d+" )

mkdir -p samples_last/
for t in $tids; do
	f=$(find samples/ -iname "*task=$t*")
	cp $f samples_last/
done

# copy a given set of tasks to analyze - selecting the last group of tasks from the last stage
#BEGIN_TASK=2570
#mkdir samples_last && find samples/ -iname "*.hpl" | ../../stack-logs-filter.py $BEGIN_TASK | xargs -I{} cp {} samples_last/ 

# dump stacks from the last stage
$DIR/stack-dump.sh samples_last/* > last_stacks_log
