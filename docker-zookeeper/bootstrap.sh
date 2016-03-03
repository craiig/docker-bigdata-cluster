#!/bin/bash

: ${ZOOKEEPER_HOME:=/usr/local/zookeeper}

$ZOOKEEPER_HOME/bin/zkServer.sh start

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

