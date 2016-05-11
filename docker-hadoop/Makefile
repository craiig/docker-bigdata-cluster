IMAGE_NAME := hadoop_master-$(shell whoami)
CONTAINER_NAME := hadoop_master-$(shell whoami)

#useful files
cid_file := build/container_id
host_file := build/hostname

include ../Makefile.options

all: $(build)

#** automated rules to write files to maintain some state for other
# docker hosts that need to know where the master is
#

#build has some dependencies on external files which we download once
#so it's easy to rebuild a container without download times
packages_dir := build/packages
packages := java.rpm \
	hadoop-native-64-2.7.1.tgz \
	hadoop-2.7.1.tar.gz
packages := $(packages:%=$(packages_dir)/%)
.PRECIOUS: $(packages)

$(packages_dir):
	mkdir -p $(packages_dir)

$(packages_dir)/java.rpm: $(packages_dir)
	curl -L \
		'http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.rpm'\
	       	-H 'Cookie: oraclelicense=accept-securebackup-cookie' > $@

$(packages_dir)/hadoop-native-64-2.7.1.tgz: $(packages_dir)
	cd $(packages_dir) && curl -LO https://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz

$(packages_dir)/hadoop-2.7.1.tar.gz: $(packages_dir)
	cd $(packages_dir) && curl -LO http://mirror.its.dal.ca/apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz


#how to build the image needed
build := build/dockerimage
build: $(build)
$(build): Dockerfile $(packages)
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

$(cid_file): $(build) | $(HADOOP_DATA_DIR)
	docker create \
		--volume=$(HADOOP_DATA_DIR):/vol/hadoop-master \
		--pid=host \
		--name $(CONTAINER_NAME) $(IMAGE_NAME)
	echo $(CONTAINER_NAME) > $@

#how to run:
start: $(cid_file) 
	docker start $(CONTAINER_NAME)
	#docker inspect --format '{{ .Config.Hostname }}' `cat build/container_id` > $(host_file)
	#below only works with bridge networking
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME) > $(host_file)
	#docker start -d $(NAME) /etc/bootstrap.sh -d > $@

$(host_file): $(cid_file)
	echo "is the container running? this won't work otherwise"
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME) > $(host_file)

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
	-rm $(host_file)

clean_container:
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)
	-rm $(build)

shell: start
	docker exec -it $(CONTAINER_NAME) bash

#iptables hacks
expose-yarn:
	sudo iptables -t nat -A  DOCKER -p tcp --dport 8088 -j DNAT --to-destination 172.17.0.2:8088
	sudo iptables -t nat -A  DOCKER -p tcp --dport 8042 -j DNAT --to-destination 172.17.0.2:8042
delete-expose-yarn:
	sudo iptables -t nat -D DOCKER 1


#** interactive commands for running a one off
# don't use these  if you don't know the difference between run and exec
run_shell: run_shell_hostnetworking

run_shell_hostnetworking:
	docker run -ti --net=host hadoop bash

run_shell_bridgenetworking:
	docker run -ti hadoop bash
