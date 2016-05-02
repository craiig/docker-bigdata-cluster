./target/scala-2.11/bdbloader_2.11-1.0.jar: ./bdbloader.scala ./bdbloader.sbt
	sbt assembly 
	#sbt package 

run: ./target/scala-2.11/bdbloader_2.11-1.0.jar
	spark-submit --class BDBLoader target/scala-2.11/bdbloader-assembly-1.0.jar accumulo 172.17.0.3 root accumulo
	 #spark-submit --class BDBLoader target/scala-2.11/bdbloader_2.11-1.0.jar

