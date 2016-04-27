all: start

IMAGE_NAME := accumulo-$(shell whoami)
CONTAINER_NAME := accumulo-$(shell whoami)
OUT := out/

#provides HADOOP_MASTER_HOSTNAME_FILE
include ../Makefile.options

ZOOKEEPER_IP_FILE := ../docker-zookeeper/build/hostname
HADOOP_IP = $(shell cat $(HADOOP_MASTER_HOSTNAME_FILE))
ZOOKEEPER_IP = $(shell cat $(ZOOKEEPER_IP_FILE))

build := build/image
build: $(build)
#TODO this build requires the IPs be known at build time, this should be re-written to use a volume
$(build): Dockerfile | $(HADOOP_MASTER_HOSTNAME_FILE) $(ZOOKEEPER_IP_FILE)
	mkdir -p $(OUT)
	cp accumulo-conf/accumulo-env.sh $(OUT)/
	sed s/HADOOPMASTERIP/${HADOOP_IP}/g accumulo-conf/accumulo-site.xml | sed s/ZOOKEEPERHOSTIP/${ZOOKEEPER_IP}/g > $(OUT)/accumulo-site.xml
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

cid_file := build/container_id

$(cid_file): $(build) 
	docker create							\
		--volumes-from zookeeper-$(shell whoami)		\
		--volumes-from hadoop_master-$(shell whoami)		\
		-v $(HADOOP_CONFIG_DIR):/usr/local/hadoop/etc/hadoop \
		--privileged=true 					\
		--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
	-rm -r $(OUT)

clean_container:
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)
	-rm $(build)

shell: start
	docker exec -it $(CONTAINER_NAME) bash

