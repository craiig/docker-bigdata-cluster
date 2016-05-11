#A basic install of hadoop for controlling stuff locally

include ../Makefile.options

all: hadoop spark

hadoop-2.7.1.tar.gz:
	wget http://mirror.its.dal.ca/apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz 

hadoop: hadoop-2.7.1.tar.gz
	mkdir -p hadoop
	tar -vzxf $< -C hadoop --strip-components=1

spark-1.6.1-bin-hadoop2.6.tgz:
	wget http://mirror.its.dal.ca/apache/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz

spark: spark-1.6.1-bin-hadoop2.6.tgz
	mkdir -p $@
	tar -vzxf $< -C $@ --strip-components=1

jdk-8u77-linux-x64.tar.gz:
	curl -L \
		'http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.tar.gz'\
		-H 'Cookie: oraclelicense=accept-securebackup-cookie' > $@

#don't run this unless you know what you're doing
# this adds the oracle JDK to the standard place where it's found on CentoS docker vms
# this is primarily to help with symbol mapping, not running java, but we'll see
java-install:
	mkdir -p /usr/java/jdk1.8.0_77/
	cp -R java/* /usr/java/jdk1.8.0_77/

java: jdk-8u77-linux-x64.tar.gz
	mkdir -p $@
	tar -vzxf $< -C $@ --strip-components=1
