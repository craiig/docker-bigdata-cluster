
TARGET:=./target/scala-2.11/bdbloader-assembly-1.0.jar

all: $(TARGET)
$(TARGET): ./bdbloader.scala ./bdbloader.sbt
	sbt assembly 
	#sbt package 

clean:
	sbt clean

run: $(TARGET)
	spark-submit --class BDBLoader $(TARGET) accumulo 172.17.0.3 root accumulo
	 #spark-submit --class BDBLoader target/scala-2.11/bdbloader_2.11-1.0.jar

