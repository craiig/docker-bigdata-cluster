# This makefile is used to tie together the rest of the docker containers
#
# for now this starts hadoop and spark
# benchmarks can be run from the spark docker container
# see docker-spark/Makefile

all:

start:
	#start hadoop master
	make -C docker-hadoop start
	#generate a config (docker container needs to be running)
	make -C ./hadoop-config-gen clean all install
	make -C ./docker-spark start

stop:
	-make -C docker-hadoop stop
	-make -C hadoop-config-gen clean
	-make -C docker-spark stop

clean:
	make -C docker-hadoop clean
	make -C ./hadoop-config-gen clean
	make -C docker-spark clean
