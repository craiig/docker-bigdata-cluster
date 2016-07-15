#!/bin/bash

mkdir -p "$SPARK_PERF_LOGS"
cd "$SPARK_PERF_LOGS"/../ || exit

result_log_files=( $(find "$PWD"/spark-perf/results/ -maxdepth 1 -type d -newer ".timestamp_file") )

cd "$SPARK_PERF_LOGS"

if [ ! -f ../.timestamp_file  ]; then
  echo ".timestamp_file not found. This is required in order to go further."
  exit 1
fi

# Check if source.sh exists. It has to exist in order to continue.
if [ ! -f ../.source.sh  ]; then
  echo ".source.sh not found. This is required in order to go further."
  exit 1
fi

# Use this for the first execution. Just to setup the execution time before
# running the benchmarks.
if [[ $1 == "--setup_exec_time" ]]; then
  execution_time=$(date +%F_%H:%M:%S)
  echo "export EXECUTION_TIME=$execution_time" > ../.source.sh
  mkdir -p "$execution_time"
  exit 0;
fi

# If a get-log execution is not already in progress, then create a inprogress
# file and continue. Otherwise exit
if [ ! -f ../.get-log-inprogress  ]; then
  touch ../.get-log-inprogress
else
  echo "get-logs.sh is already in progress."
  echo "If you think that this is an error remove the .get-log-inprogress file"
  echo "Exiting."
  exit 1
fi


# Get the timestamp that is in .source.sh
source ../.source.sh
mkdir -p "$EXECUTION_TIME"/benchmarks
cd "$EXECUTION_TIME"/benchmarks || exit


hdfs dfs -get /spark_event_logs ./


# Count is only used to skip the first iteration of the below for loop. The
# first iteration has folder = $PWD/spark-perf/results/ which is the folder I
# was looking in to find useful stuff. So that folder as a result is useless.
count=0
for folder in "${result_log_files[@]}"; do
  # Skip index 0
  if (( count > 0 )); then

    # Spark-perf result logs
    # Iterate for every file that is in folder of spark-perf/results
    # file will end up being something like "<path to file>/glm-regression.err"
    for file in $folder/*.err; do
      # Remove the path from the file, so we are just left with the filename
      filename=$(basename "$file")
      # Create a folder with that name, but remove the extension of the file
      mkdir -p "${filename%.*}"
      cd "${filename%.*}" || exit

      ## Result Logs
      # Symlink all the .err and .out files for that category if this is not the
      # last run. Otherwise, delete the symlinks and copy the files over.
      if [[ $1 == "--last_exec" ]]; then
        rm -rf "${filename%.*}".err
        rm -rf "${filename%.*}".out
        cp $folder/"${filename%.*}".err ./
        cp $folder/"${filename%.*}".out ./
      else
        ln -sf $folder/"${filename%.*}".err
        ln -sf $folder/"${filename%.*}".out
      fi


      # Search for the app_ids of each category and stick them into a list
      app_ids=( $(grep -o 'app-[0-9]\{14\}-[0-9]\{4\}' "${filename%.*}".err) )

      ## Executor Logs
      mkdir -p executor_logs
      cd executor_logs || exit
      for app in "${app_ids[@]}"; do
      # Symlink all the executor logs if this is not the last run. Otherwise,
      # delete the symlinks and copy the files over.
      if [[ $1 == "--last_exec" ]]; then
        rm -rf "$app"
        cp -r "$EXECUTOR_LOGS/$app" ./
      else
        rm -rf "$app"
        ln -sf "$EXECUTOR_LOGS/$app"
      fi

      done
      cd .. || exit

      # Event Logs
      mkdir -p event_logs
      cd event_logs || exit
      # Remove the inprogress files. This way if it turns out that that app_id
      # is not in progress anymore, the inprogress file will not appear from now
      # on.
      rm -rf *.inprogress
      for app in "${app_ids[@]}"; do
        # Try both of these locations. Send stdout and stderr to /dev/null
        # though for the first one, since if it isn't there we probably already
        # moved it to /mnt/scratch somewhere.
        mv  ../../spark_event_logs/${app} ./ > /dev/null 2>&1
        mv  ../../spark_event_logs/${app}.inprogress ./ > /dev/null 2>&1
      done
      cd ../.. || exit
    done
  fi
  ((count++))
done

rm -rf spark_event_logs

cd "$SPARK_PERF_LOGS"/../ || exit
echo "Logs saved into logs/$EXECUTION_TIME"
rm -rf .get-log-inprogress
