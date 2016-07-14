all: start

IMAGE_NAME := accumulo-$(shell whoami)
CONTAINER_NAME := accumulo-$(shell whoami)
OUT := out/

cid_file := build/container_id
host_file := build/hostname

#provides HADOOP_MASTER_HOSTNAME_FILE
include ../Makefile.options

HADOOP_IP = $(shell cat $(HADOOP_MASTER_HOSTNAME_FILE))
# using docker linking instead of IP copying to make networking more reliable
ZOOKEEPER_DOCKER_CONTAINER = zookeeper-$(shell whoami)

#build has some dependencies on external files which we download once
#so it's easy to rebuild a container without download times
packages_dir := build/packages
packages := java.rpm
packages := $(packages:%=$(packages_dir)/%)
.PRECIOUS: $(packages)

$(packages_dir):
		mkdir -p $(packages_dir)

$(packages_dir)/java.rpm: | $(packages_dir)
		curl -L \
					'http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.rpm'\
							-H 'Cookie: oraclelicense=accept-securebackup-cookie' > $@


build := build/image
build: $(build)
#TODO this build requires the IPs be known at build time, this should be re-written to use a volume
$(build): Dockerfile | $(HADOOP_MASTER_HOSTNAME_FILE) $(ZOOKEEPER_IP_FILE) $(packages)
	mkdir -p $(OUT)
	cp accumulo-conf/accumulo-env.sh $(OUT)/
	sed s/HADOOPMASTERIP/${HADOOP_IP}/g accumulo-conf/accumulo-site.xml | sed s/ZOOKEEPERHOSTIP/${ZOOKEEPER_DOCKER_CONTAINER}/g > $(OUT)/accumulo-site.xml
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@


$(cid_file): $(build) 
	docker create							\
		--volumes-from zookeeper-$(shell whoami)		\
		--volumes-from hadoop_master-$(shell whoami)		\
		-v $(HADOOP_CONFIG_DIR):/usr/local/hadoop/etc/hadoop \
		--privileged=true 					\
		--pid=host \
		--link $(ZOOKEEPER_DOCKER_CONTAINER):$(ZOOKEEPER_DOCKER_CONTAINER) \
		--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME) > $(host_file)

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
	-echo if you want to clean the data, run: hdfs dfs -rm -R /accumulo
	-rm -r $(OUT)

clean_container:
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)
	-rm $(build)

shell: start
	docker exec -it $(CONTAINER_NAME) bash

