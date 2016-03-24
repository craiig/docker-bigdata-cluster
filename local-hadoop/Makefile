#A basic install of hadoop for controlling stuff locally

include ../Makefile.options

all: hadoop

hadoop-2.7.1.tar.gz:
	wget http://mirror.its.dal.ca/apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz 

hadoop: hadoop-2.7.1.tar.gz
	mkdir -p hadoop
	tar -vzxf $< -C hadoop --strip-components=1
