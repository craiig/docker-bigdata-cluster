TARGET:=./target/scala-2.11/kmeans-assembly-1.0.jar


ifeq ($(LOCAL),1)
SPARK_SUBMIT_ARGS :=
PROFILE_NAME := accumulo-rankings-local
export LOCAL
$(warning export local)
else
SPARK_SUBMIT_ARGS := --deploy-mode=cluster --master yarn --num-executors 10 --executor-memory=1g
# SPARK_SUBMIT_ARGS_LOCAL := --master local[4]
PROFILE_NAME := accumulo-rankings-cluster
endif

ifdef LOCAL
# override the local environment while make is running:
export HADOOP_CONF_DIR=""
SPARK_SUBMIT_ARGS := --master local[$(LOCAL)]
endif

SPARK_SUBMIT := spark-submit $(SPARK_SUBMIT_ARGS)
# SPARK_SUBMIT_LOCAL := spark-submit $(SPARK_SUBMIT_ARGS_LOCAL)

all: $(TARGET)
$(TARGET): ./kmeans.scala ./kmeans.sbt
	sbt assembly
	#sbt package

clean:
	sbt clean

run-kmeans: $(TARGET)
ifdef LOCAL
	rm -rf myModelPath
else
	# Remove files that were left over from previous executions
	hdfs dfs -rm -r -f /user/root/myModelPath/data
	hdfs dfs -rm -r -f /user/root/myModelPath/metadata
	hdfs dfs -put -f kmeans_data.txt /user/root/data/mllib/
endif
	$(SPARK_SUBMIT) --class benchKmeans $(TARGET) accumulo 172.17.0.3 root accumulo

# run-kmeans-local: $(TARGET)
# 	$(SPARK_SUBMIT_LOCAL) --class benchKmeans $(TARGET)

perf-kmeans:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-load -- make perf-kmeans2

perf-kmeans2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class benchKmeans $(TARGET) accumulo 172.17.0.3 root accumulo"

