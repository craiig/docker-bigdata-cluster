include ../../Makefile.options
include ../Makefile.options
TARGET:=./target/scala-2.11/bdbloader-assembly-1.0.jar

ifeq ($(CLUSTER),1)
PROFILE_NAME := accumulo-rankings-cluster
else
PROFILE_NAME := accumulo-rankings-local
endif

all: $(TARGET)
$(TARGET): ./bdbloader.scala ./bdbloader.sbt
	sbt assembly 
	#sbt package 

clean:
	sbt clean

ZOOKEEPER := $(shell cat ../../docker-zookeeper/build/hostname)

run-loader: $(TARGET)
	$(SPARK_SUBMIT) --class BDBLoader $(TARGET) accumulo $(ZOOKEEPER) root accumulo

perf-loader:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-load -- make perf-loader2

perf-loader2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class BDBLoader $(TARGET) accumulo $(ZOOKEEPER) root accumulo"

run-reader: $(TARGET)
	$(SPARK_SUBMIT) --class BDBReader $(TARGET) accumulo $(ZOOKEEPER) root accumulo

perf-reader:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-read -- make perf-reader2 LOCAL=$(LOCAL)

perf-reader2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class BDBReader $(TARGET) accumulo $(ZOOKEEPER) root accumulo"


copy-data-to-hdfs-1node:
	hdfs dfs -rm -r -f /user/spark/benchmark
	hdfs dfs -mkdir -p /user/spark/benchmark
	hdfs dfs -put -f ../bdb/data//text-deflate/1node/rankings /user/spark/benchmark/rankings
	hdfs dfs -put -f ../bdb/data//text-deflate/1node/uservisits /user/spark/benchmark/uservisits
	hdfs dfs -put -f ../bdb/data//text-deflate/1node/crawl /user/spark/benchmark/crawl
	hdfs dfs -cp /user/spark/benchmark/rankings /user/spark/benchmark/scratch
