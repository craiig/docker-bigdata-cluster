
TARGET:=./target/scala-2.11/bdbloader-assembly-1.0.jar

all: $(TARGET)
$(TARGET): ./bdbloader.scala ./bdbloader.sbt
	sbt assembly 
	#sbt package 

clean:
	sbt clean

run-loader: $(TARGET)
	spark-submit --class BDBLoader $(TARGET) accumulo 172.17.0.3 root accumulo

run-reader: $(TARGET)
	spark-submit --class BDBReader $(TARGET) accumulo 172.17.0.3 root accumulo

perf-loader:
	sudo ../../profiler/profiler.sh accumulo-rankings-load -- make perf-loader2

perf-loader2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit --class BDBLoader $(TARGET) accumulo 172.17.0.3 root accumulo"

