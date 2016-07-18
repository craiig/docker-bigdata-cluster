#!/bin/bash

# frequency_of_events#{{{
function frequency_of_events {
  # Combine all app log files into one file called file
  find . -name "app*" | xargs -n 1  -I '{}' cat '{}' >> file

  # Remove -- "Event":" -- from all lines
  sed -i "s@{\"Event\":\"@@g" file

  # Remove -- " -- To the eol
  sed -i "s@\".*@@g" file
}

#}}}

if [ -z "$1" ]; then
  echo "Help Menu"
  echo ""
  echo "\"get-event.sh <path to benchmark logs>\" runs for only the specified benchmark"
  echo "\"get-event.sh --all <path to root of logs>\" runs for all benchmarks"
  echo "\"get-event.sh --file <path to list of benchmarks>\" runs for all benchmarks that are specified in the file"
  echo ""
  echo "Example:"
  echo "    \"get-event.sh logs/2016-07-14_23-36-06/glm-regression\""
  echo "    \"get-event.sh --all logs/2016-07-14_23-36-06/\""
  echo "    \"get-event.sh --file ./myfile\""
  echo ""
  echo "Example myfile:"
  echo "     logs/2016-07-14_23-36-06/glm-regression"
  echo "     logs/2016-07-14_23-36-06/glm-classification"
  echo "     logs/2016-07-14_23-36-06/kmeans"
  echo "     logs/2016-07-14_23-36-06/als"
  exit 0
fi

start_dir=$(pwd)

# If the second argument doesn't exist it must be the case that we are not doing
# all of the logs, but just a specific benchmark
if [ -z "$2" ]; then
  # In this case, the target directory is specified by $1, so go there
  cd "$1"
  specified_dir=$(pwd)
  cd event_logs

  rm -rf file
  touch file

  # append the frequencies of all the events to the same files and parse them
  frequency_of_events
  cd "$specified_dir"
  mv $directory/event_logs/file ./

  # If the first argument happens to be "--all" we will run the script for all
  # benchmarks
elif [[ "$1" == "--all" ]]; then
  # In this case, the target directory is specified by $2, so go there
  cd "$2"
  specified_dir=$(pwd)

  rm -rf file
  touch file
  for directory in *
  do
    # If I can't get into the folder, just skip it. It could be a regular file
    # that got in there somehow.
    cd $directory/event_logs > /dev/null 2>&1 || continue
    echo "$directory"
    mv ../../file ./
    # append the frequencies of all the events to the same files and parse them
    frequency_of_events
    cd "$specified_dir"
    mv $directory/event_logs/file ./
  done

elif [[ "$1" == "--file" ]]; then
  # In this case, $2 holds the location of a file to read. This file will
  # contain a list of benchmarks
  benchmarks=($(cat "$2"))
  specified_dir=$(pwd)

  rm -rf file
  touch file
  for directory in "${benchmarks[@]}"
  do
    # If I can't get into the folder, just skip it. It could be a regular file
    # that got in there somehow.
    cd $directory/event_logs > /dev/null 2>&1 || continue
    echo "$directory"
    mv "$specified_dir"/file ./
    # append the frequencies of all the events to the same files and parse them
    frequency_of_events
    cd "$specified_dir"
    mv $directory/event_logs/file ./
  done

else
  echo "error"
  exit 1
fi

# remove duplicates and find number of occurences
sort file | uniq -c > tmp && mv tmp file
sort -bnr file > tmp && mv tmp file

cd "$start_dir"
mv "$specified_dir"/file frequency_of_events.txt

