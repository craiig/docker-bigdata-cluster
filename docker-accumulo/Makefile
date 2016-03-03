all: start

IMAGE_NAME := accumulo-$(shell whoami)
CONTAINER_NAME := accumulo-$(shell whoami)
OUT := out/

HADOOP_IP_FILE := ../docker-hadoop/build/hostname
ZOOKEEPER_IP_FILE := ../docker-zookeeper/build/hostname

HADOOP_IP := $(shell cat $(HADOOP_IP_FILE))
ZOOKEEPER_IP := $(shell cat $(ZOOKEEPER_IP_FILE))

include ../Makefile.options

build := build/image
build: $(build)
$(build): Dockerfile
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .

cid_file := build/container_id

$(cid_file): $(build) $(HADOOP_CONFIG_DIR)/core-site.xml
	mkdir -p $(OUT)
	cp accumulo-conf/accumulo-env.sh $(OUT)/
	sed s/HADOOPMASTERIP/${HADOOP_IP}/g accumulo-conf/accumulo-site.xml | sed s/ZOOKEEPERHOSTIP/${ZOOKEEPER_IP}/g > $(OUT)/accumulo-site.xml
	docker create							\
		--volumes-from zookeeper-$(shell whoami)		\
		--volumes-from hadoop_master-$(shell whoami)		\
		--privileged=true 					\
		--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)

stop:
	-docker stop $(CONTAINER_NAME)

clean: clean_container clean_image
	rm -r $(OUT)

clean_container:
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) bash

