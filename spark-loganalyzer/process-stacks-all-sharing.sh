#!/usr/bin/env bash
# output new analysis for all files

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

process() {
	log=$1
	name=$2
	#echo $(dirname $log)

	if [[ "$RUNTIME_FILE" != "" ]]; then
		runtime=$(../analyzer.py -e $DIR/$(dirname $log)/app* | grep "Executor Run Time" | tail -1 | grep -Po "\d+")
		echo $name, $runtime >> $RUNTIME_FILE
	fi


	if [[ "$STACKS_FILE" != "" ]]; then
		cat $DIR/$log | $DIR/stack-analyzer.py -n "$name" -s >> $STACKS_FILE
		echo >> $STACKS_FILE
	fi
}

if [[ "$RUNTIME_FILE" != "" ]]; then
	echo "benchmark, runtime" > $RUNTIME_FILE
fi
if [[ "$STACKS_FILE" != "" ]]; then
	echo "benchmark,subsystem,samples" > $STACKS_FILE
fi

process ./logs/accumulo_primary/last_stacks_log "Accumulo Baseline"
process ./logs/accumulo_primary_serializer=none/last_stacks_log "Accumulo Baseline No Ser"
process ./logs/accumulo_primary_serializer=kryo/last_stacks_log "Accumulo Baseline Kryo"

process ./logs/accumulo_primary_cached/last_stacks_log "Accumulo Local Cache"
process ./logs/accumulo_primary_cached_serializer=none/last_stacks_log "Accumulo Local Cache No Ser"
process ./logs/accumulo_primary_cached_serializer=kryo/last_stacks_log "Accumulo Local Cache Kryo"

process ./logs/accumulo_secondary/last_stacks_log "Accumulo Remote Cache"
process ./logs/accumulo_secondary_serializer=none/last_stacks_log "Accumulo Remote Cache No Ser"
process ./logs/accumulo_secondary_serializer=kryo/last_stacks_log "Accumulo Remote Cache Kryo"

process ./logs/hdfs_primary/last_stacks_log "HDFS Baseline"
process ./logs/hdfs_primary_serializer=none/last_stacks_log "HDFS Baseline No Ser"
process ./logs/hdfs_primary_serializer=kryo/last_stacks_log "HDFS Baseline Kryo"

process ./logs/hdfs_primary_cached/last_stacks_log "HDFS Local Cache"
process ./logs/hdfs_primary_cached_serializer=none/last_stacks_log "HDFS Local Cache No Ser"
process ./logs/hdfs_primary_cached_serializer=kryo/last_stacks_log "HDFS Local Cache Kryo"
process ./logs/hdfs_secondary/last_stacks_log "HDFS Remote Cache"
process ./logs/hdfs_secondary_serializer=none/last_stacks_log "HDFS Remote Cache No Ser"
process ./logs/hdfs_secondary_serializer=kryo/last_stacks_log "HDFS Remote Cache Kryo"

