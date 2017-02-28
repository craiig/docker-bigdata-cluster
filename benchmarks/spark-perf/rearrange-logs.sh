#!/bin/bash

# idea is to rearrange logs from:
# results/userlogs/app_id...
# into:
# results/benchmark_name/
# run this from the results directory of your choice
set -e

folder=./

for file in $folder/*.err; do
	echo "finding app ids for ${file}"
	app_ids=( $(grep -Po 'application_\d+_\d+' "${file}" | sort | uniq) )

	for app in "${app_ids[@]}"; do
		mv "userlogs/${app}" ${file%.*}
	done
done
