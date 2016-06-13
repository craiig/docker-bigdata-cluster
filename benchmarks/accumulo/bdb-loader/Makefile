TARGET:=./target/scala-2.11/bdbloader-assembly-1.0.jar

ifeq ($(LOCAL),1)
SPARK_SUBMIT_ARGS := 
PROFILE_NAME := accumulo-rankings-local
export LOCAL
$(warning export local)
else
SPARK_SUBMIT_ARGS := --deploy-mode=cluster --master yarn --num-executors 10 --executor-memory=1g
PROFILE_NAME := accumulo-rankings-cluster
endif

SPARK_SUBMIT := spark-submit $(SPARK_SUBMIT_ARGS)

all: $(TARGET)
$(TARGET): ./bdbloader.scala ./bdbloader.sbt
	sbt assembly 
	#sbt package 

clean:
	sbt clean

run-loader: $(TARGET)
	$(SPARK_SUBMIT) --class BDBLoader $(TARGET) accumulo 172.17.0.3 root accumulo

perf-loader:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-load -- make perf-loader2

perf-loader2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class BDBLoader $(TARGET) accumulo 172.17.0.3 root accumulo"

run-reader: $(TARGET)
	$(SPARK_SUBMIT) --class BDBReader $(TARGET) accumulo 172.17.0.3 root accumulo

perf-reader:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-read -- make perf-reader2 LOCAL=$(LOCAL)

perf-reader2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class BDBReader $(TARGET) accumulo 172.17.0.3 root accumulo"
