IMAGE_NAME := hadoop_master-$(shell whoami)
CONTAINER_NAME := hadoop_master-$(shell whoami)

#useful files
cid_file := build/container_id
host_file := build/hostname

all: $(build)

#** automated rules to write files to maintain some state for other
# docker hosts that need to know where the master is
#
#how to build the image needed
build := build/dockerimage
build: $(build)
$(build): Dockerfile
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

$(cid_file): $(build)
	docker create --name $(CONTAINER_NAME) $(IMAGE_NAME)
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


#** interactive commands for running a one off
# don't use these  if you don't know the difference between run and exec
run_shell: run_shell_hostnetworking

run_shell_hostnetworking:
	docker run -ti --net=host hadoop bash

run_shell_bridgenetworking:
	docker run -ti hadoop bash
