#!/bin/bash

CONFIG_PATH=./spark-perf/config

#local_config {{{
function local_config {
  sed -i '/SPARK_CLUSTER_URL = /c\SPARK_CLUSTER_URL = \"spark:\/\/%s:7077 % socket.gethostname()\"' $CONFIG_PATH/config.py
  sed -i '/SCALE_FACTOR = /c\SCALE_FACTOR = 0.05' $CONFIG_PATH/config.py
  sed -i '/SPARK_DRIVER_MEMORY = /c\SPARK_DRIVER_MEMORY = \"512m\"' $CONFIG_PATH/config.py
  sed -i '/spark\.executor\.memory/c\# JavaOptionSet(\"spark\.executor\.memory\", \[\"2g\"\]),' $CONFIG_PATH/config.py
}

#}}}
# default_config {{{
function default_config {
  if [[ "$HOSTNAME" == "miga" ]]; then
    sed -i '/SPARK_CLUSTER_URL = /c\SPARK_CLUSTER_URL = \"spark:\/\/miga:7077\"' $CONFIG_PATH/config.py
    sed -i '/SCALE_FACTOR = /c\SCALE_FACTOR = 0.05' $CONFIG_PATH/config.py
    sed -i '/SPARK_DRIVER_MEMORY = /c\SPARK_DRIVER_MEMORY = \"1g\"' $CONFIG_PATH/config.py
    sed -i '/spark\.executor\.memory/c\# JavaOptionSet(\"spark\.executor\.memory\", \[\"2g\"\]),' $CONFIG_PATH/config.py
  elif [[ "$HOSTNAME" == "octavia" ]]; then
    sed -i '/SPARK_CLUSTER_URL = /c\SPARK_CLUSTER_URL = \"spark:\/\/octavia:7077\"' "$CONFIG_PATH"/config.py
    sed -i '/SCALE_FACTOR = /c\SCALE_FACTOR = 0.05' "$CONFIG_PATH"/config.py
    sed -i '/SPARK_DRIVER_MEMORY = /c\SPARK_DRIVER_MEMORY = \"1g\"' "$CONFIG_PATH"/config.py
    sed -i '/spark\.executor\.memory/c\# JavaOptionSet(\"spark\.executor\.memory\", \[\"2g\"\]),' "$CONFIG_PATH"/config.py
  else
    sed -i '/SPARK_CLUSTER_URL = /c\SPARK_CLUSTER_URL = \"spark:\/\/localhost:7077\"' $CONFIG_PATH/config.py
    sed -i '/SCALE_FACTOR = /c\SCALE_FACTOR = 0.05' $CONFIG_PATH/config.py
    sed -i '/SPARK_DRIVER_MEMORY = /c\SPARK_DRIVER_MEMORY = \"1g\"' $CONFIG_PATH/config.py
    sed -i '/spark\.executor\.memory/c\# JavaOptionSet(\"spark\.executor\.memory\", \[\"2g\"\]),' $CONFIG_PATH/config.py
  fi
}
#}}}
# run {{{
function run {
  cd spark-perf
  ./bin/run
}

#}}}


if [[ "$1" == "config" ]]; then
  echo "Creating config.py file..."
  cp -f $CONFIG_PATH/config.py.template $CONFIG_PATH/config.py

  # set spark_home_dir to $SPARK_BIN
  sed -i '/SPARK_HOME_DIR = /c\SPARK_HOME_DIR = \"'"$SPARK_BIN"'\"' $CONFIG_PATH/config.py

  sed -i '/RUN_SPARK_TESTS = /c\RUN_SPARK_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/RUN_PYSPARK_TESTS = /c\RUN_PYSPARK_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/RUN_STREAMING_TESTS = /c\RUN_STREAMING_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/RUN_MLLIB_TESTS = /c\RUN_MLLIB_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/RUN_PYTHON_MLLIB_TESTS = /c\RUN_PYTHON_MLLIB_TESTS = True' $CONFIG_PATH/config.py

  sed -i '/PREP_SPARK_TESTS = /c\PREP_SPARK_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/PREP_PYSPARK_TESTS = /c\PREP_PYSPARK_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/PREP_STREAMING_TESTS = /c\PREP_STREAMING_TESTS = True' $CONFIG_PATH/config.py
  sed -i '/PREP_MLLIB_TESTS = /c\PREP_MLLIB_TESTS = True' $CONFIG_PATH/config.py

  if [[ "$2" == "local" ]]; then
    echo "Create a config for local execution"
    local_config
  else
    echo "Create a config for spark cluster execution"
    default_config
  fi
else
  echo "Running tests"
  run
fi

echo "Done!"
