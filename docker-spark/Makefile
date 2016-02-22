all: start

IMAGE_NAME := spark
CONTAINER_NAME := spark

#needs HADOOP_CONFIG_DIR
include ../Makefile.options

build := build/image
build: $(build)
$(build): Dockerfile
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
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)
	-rm $(build)

shell:
	docker exec -it $(CONTAINER_NAME) bash


#old interactive commands

run_shell:
	docker run -ti $(NAME) bash

#don't use this, just for reference
spark-test:
	./bin/spark-submit --class org.apache.spark.examples.SparkPi \
	    --master yarn \
	    --deploy-mode cluster \
	    --driver-memory 4g \
	    --executor-memory 2g \
	    --executor-cores 1 \
	    lib/spark-examples*.jar \
	    10
