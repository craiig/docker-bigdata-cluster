include ../../Makefile.options
include ../Makefile.options
TARGET:=./target/scala-2.11/arjoin_2.11-1.0.jar

ifeq ($(CLUSTER),1)
PROFILE_NAME := arjoin-rankings-cluster
else
PROFILE_NAME := arjoin-rankings-local
endif

all: $(TARGET)
$(TARGET): ./arjoin.scala ./arjoin.sbt
	#sbt assembly 
	sbt package 

clean:
	sbt clean

run: $(TARGET)
	$(SPARK_SUBMIT) --class ARJoin $(TARGET) 

copy-data-to-hdfs:
	hdfs dfs -mkdir -p /user/spark/benchmark/amazon_reviews/
	hdfs dfs -put -f /mnt/scratch/benchmark_data/amazon_reviews/* /user/spark/benchmark/amazon_reviews/

get-logs:
	 docker exec hadoop_master-cam14 bash -c "tar -c /usr/local/hadoop/logs/userlogs/*" | tar -x -C . --strip-components=4 -k
