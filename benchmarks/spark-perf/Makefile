#!/bin/bash

all:
	@# If their is less than 2GB (2000000KB) of disk space left, don't run the
	@# script
	@#
	@# If both files do not exist then start up the script. Create the two files,
	@# populate it with the first execution of get-logs.sh, run the benchmarks
	@# then after the tests, run get-logs again, and remove the files
	@#
	@# If both files exist, run get-logs.sh
	@#
	@# Otherwise, Return an error
	@ if [ ! -f .source.sh -a ! -f .timestamp_file ] ; \
	then \
		available_disk_kb=$$(df -k . | cut -d' ' -f4) ; \
		if [ "$$available_disk_kb" -lt "2000000" ]; \
		then \
			echo "Not Enough Disk Space to Execute Spark-Perf!" ; \
			exit 1 ; \
		fi ; \
		touch .timestamp_file ; \
		touch .source.sh ; \
		./get-logs.sh --setup_exec_time ; \
		./run-script.sh ; \
		./get-logs.sh --last_exec ; \
		rm -rf .timestamp_file ; \
		rm -rf .source.sh ; \
		rm -rf .get-log-inprogress \
	elif [ -f .source.sh -a -f .timestamp_file ] ; \
	then \
		echo "Fetching the Logs" ; \
		./get-logs.sh ; \
	else \
		echo "Something went wrong!" ; \
		echo "One of the files: .source.sh or .timestamp_file are missing" ; \
	fi;

generate-config-local:
	./run-script.sh config local

generate-config-cluster:
	./run-script.sh config

clean:
	rm -rf .timestamp_file
	rm -rf .source.sh
	rm -rf .get-log-inprogress
