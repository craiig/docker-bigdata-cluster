#!/usr/bin/env bash
set -e
set -x
# clears spark logs
docker exec -u 0 hadoop_master-cam14 bash -c "rm -rf /usr/local/hadoop/logs/userlogs/*"
