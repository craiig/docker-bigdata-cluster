#!/usr/bin/env bash
# loads userlogs into the current directory
docker exec -u 0 hadoop_master-cam14 bash -c "tar -c /usr/local/hadoop/logs/userlogs" | tar -x -C ./ --strip-components=4 -k
