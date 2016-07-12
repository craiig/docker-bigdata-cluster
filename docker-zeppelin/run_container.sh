#!/usr/bin/env bash

/usr/local/zeppelin/bin/zeppelin-daemon.sh start 2>&1 | tee /usr/local/zeppelin/debug-daemon-start
while true; do sleep 1000; done
