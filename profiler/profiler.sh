#!/bin/bash

# sudo ./profiler.sh $(name) $(cmd)
# 0. runs $(cmd) (include any docker invocation stuff in your cmd)
# 1. runs system wide perf while the command is running
# 2. collects all perf.map files, and command output into a timestamped directory
# 3. upload the perf output to a sql database

#configuration
STORAGE=/mnt/scratch/cam14/profiler-storage/
# 9999hz = 1 sample every 100.1 microseconds
PERF_FREQ=9999

# check for name and command in arguments
if [[ -z $1 || -z $2 || $2 != "--" || -z $3 ]]; then
	echo "usage: $0 <name> -- <command>"
	echo $1
	echo $2
	echo $3
	exit
fi
NAME=$1
shift
shift # eliminate '--'

#specifically escape each argument
for PARAM in "$@"
do
  r=$(printf '%q' "$PARAM")
  CMD="${CMD} ${r}"
done

#check for root because we need it to collect accurate information
if [[ $(whoami) != 'root' ]]; then
	echo "please run profiler as root"
	exit
fi

#setup variables
OUTDIR=$STORAGE/$(date +%Y%m%d-%H%M%S)-$NAME
mkdir -p $OUTDIR

#0 + 1 run perf with $(cmd)
perf record -F $PERF_FREQ -ag -o $OUTDIR/perf.data -- bash -c "$CMD" \
	| tee $(OUTDIR)/run.output
#perf record -F $PERF_FREQ -ag -o $OUTDIR/perf.data -- bash "$temp"
if [ $? -eq 0 ]; then
    echo OK
else
    echo FAIL
    exit
fi

#1.5 compress perf.data to keep storage down
gzip -9 $OUTDIR/perf.data

#2. collect perf map files from all running docker containers
# this is a bit of a sledgehammer but so long as all docker containers
# are running with system pids, this should be OK
# make sure to throw an error if there's an overwrite
#containers=$(docker ps -q)
containers=$(docker ps | awk '{if(NR>1) print $NF}')
for d in $containers; do
	docker exec $d bash -c "tar -c /tmp/perf-*.map" | tar -x -C $OUTDIR --strip-components=1 -k
done
chmod a+rw perf-*.map
chown `whoami` perf-*.map
