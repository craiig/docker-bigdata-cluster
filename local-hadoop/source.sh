#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:$DIR/hadoop/bin:$DIR/spark/bin

export HADOOP_USER_NAME=root

export HADOOP_PREFIX=$DIR/hadoop
export HADOOP_COMMON_HOME=$HADOOP_PREFIX
export HADOOP_HDFS_HOME=$HADOOP_PREFIX
export HADOOP_MAPRED_HOME=$HADOOP_PREFIX
export HADOOP_YARN_HOME=$HADOOP_PREFIX
#export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
#export HADOOP_CONF_DIR=~/docker-volumes/hadoop-config/
export HADOOP_CONF_DIR=$DIR/../hadoop-config-gen/out
export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
export SPARK_BIN=$DIR/spark
export SPARK_PERF_LOGS=$DIR/../benchmarks/spark-perf/logs
export EXECUTOR_LOGS=$DIR/spark/work

#optional java instrumenation
export JAVA_HOME="/usr/java/jdk1.8.0_77/"
export JAVA_TOOL_OPTIONS=""
#export JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentpath:$DIR/../perf-map-agent/out/libperfmap.so"
#export JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so -agentlib:hprof"
#export JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentlib:hprof=heap=sites"
#export JAVA_TOOL_OPTIONS="-agentlib:hprof=heap=sites"
