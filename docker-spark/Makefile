all: start

IMAGE_NAME := spark-$(shell whoami)
CONTAINER_NAME := spark-$(shell whoami)

#needs HADOOP_CONFIG_DIR
include ../Makefile.options

spark-1.6.0-bin-hadoop2.6.tgz:
	wget http://mirror.its.dal.ca/apache/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz

build := build/image
build: $(build)
$(build): Dockerfile spark-1.6.0-bin-hadoop2.6.tgz
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

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

clean: clean_container clean_image
clean_container:
	-docker rm -v $(CONTAINER_NAME) && rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME) && rm $(build)

shell: start
	docker exec -it $(CONTAINER_NAME) bash

#command that runs a test against the hadoop setup - should work
test: start
	docker exec -it $(CONTAINER_NAME) \
	sh -c 'cd /usr/local/spark && \
	./bin/spark-submit --class org.apache.spark.examples.SparkPi \
	    --master yarn \
	    --deploy-mode cluster \
	    --driver-memory 4g \
	    --executor-memory 2g \
	    --executor-cores 1 \
	    lib/spark-examples*.jar \
	    10'
