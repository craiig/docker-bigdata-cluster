#!/usr/bin/env bash

nohup /usr/sbin/sshd
cd /usr/local/alluxio
bash -x ./bin/alluxio-start.sh local
trap '/usr/local/alluxio/bin/alluxio-stop.sh' SIGTERM

while true; do sleep 1000; done
