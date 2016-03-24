#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:$DIR/hadoop/bin

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
