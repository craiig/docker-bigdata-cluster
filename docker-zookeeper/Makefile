all: start

IMAGE_NAME := zookeeper-$(shell whoami)
CONTAINER_NAME := zookeeper-$(shell whoami)

hostname := build/hostname

include ../Makefile.options

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
$(build): Dockerfile $(packages)
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	echo $(IMAGE_NAME) > $(build)

cid_file := build/container_id

$(cid_file): $(build)
	docker create					\
		-v /usr/local/zookeeper			\
		--privileged=true			\
		--pid=host \
		--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME) > $(hostname)

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
	-rm $(hostname)

clean_container:
	-docker rm -v $(CONTAINER_NAME)
	-rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME)
	rm $(build)

shell:
	docker exec -it $(CONTAINER_NAME) bash

