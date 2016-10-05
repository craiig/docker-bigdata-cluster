#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
	echo "usage $0 <shell.log>"
	exit 1
fi

application_id=$( grep -Po "application_\d+_\d+" $1 | head -n 1 )

docker_id=$(docker ps | grep hadoop_master-$(whoami) | awk '{print $1}')

$DIR/grab-logs-docker.sh $application_id $docker_id
$DIR/grab-event-logs-hdfs.sh $application_id

#after logs come back from docker we can check for an yourkit samples
samples=$(grep -iPoh '(?<=CPU Sampling Stopped. Log stored at: )(.*)' container_*/stderr)

if [ ! -z "$samples" ]; then
	mkdir -p samples
	for s in $samples; do
		echo $s
		docker cp $docker_id:$s samples/$(basename $s)
		docker exec -t $docker_id rm $s
		#docker exec -t $docker_id bash -c "sudo tar -c $s" | tar -x -C ./samples
	done
	#docker exec -t $docker_id bash -c "sudo tar -c $samples" | tar -x -C ./samples
fi
