all: start

IMAGE_NAME := zookeeper-$(shell whoami)
CONTAINER_NAME := zookeeper-$(shell whoami)

include ../Makefile.options

build := build/image
build: $(build)
$(build): Dockerfile
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .

cid_file := build/container_id

$(cid_file): $(build)
	docker create					\
		-v /usr/local/zookeeper			\
		--privileged=true			\
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

shell:
	docker exec -it $(CONTAINER_NAME) bash

