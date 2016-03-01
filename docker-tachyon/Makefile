all: start

IMAGE_NAME := tachyon-$(shell whoami)
CONTAINER_NAME := tachyon-$(shell whoami)

#needs HADOOP_CONFIG_DIR
include ../Makefile.options

#some packages
alluxio-1.0.0-bin.tar.gz:
	wget http://alluxio.org/downloads/files/1.0.0/alluxio-1.0.0-bin.tar.gz

build := build/image
build: $(build)
$(build): Dockerfile alluxio-1.0.0-bin.tar.gz build/conf/alluxio-env.sh
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

#generate a templated config based on the hadoop master's ip
build/conf/alluxio-env.sh: tachyon-conf/alluxio-env.sh $(HADOOP_MASTER_HOSTNAME_FILE)
	mkdir -p build/conf
	sed s/{{MASTER}}/${HADOOP_MASTER_HOSTNAME}/g $< > $@

cid_file := build/container_id
$(cid_file): $(build) $(HADOOP_CONFIG_DIR)/core-site.xml 
	docker create \
		-v $(HADOOP_CONFIG_DIR):/usr/local/hadoop/etc/hadoop \
		--privileged=true \
	       	--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
clean_container:
	-docker rm -v $(CONTAINER_NAME) && rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME) && rm $(build)
	-rm -rf build/conf/

shell: start
	docker exec -it $(CONTAINER_NAME) bash

test: start
	docker exec -it $(CONTAINER_NAME) \
	sh -c 'cd /usr/local/alluxio && ./bin/alluxio runTests'

