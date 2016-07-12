all: start

IMAGE_NAME := zeppelin-$(shell whoami)
CONTAINER_NAME := zeppelin-$(shell whoami)
DOCKER_EXEC := docker exec $(CONTAINER_NAME)

#needs HADOOP_CONFIG_DIR
include ../Makefile.options

#build has some dependencies on external files which we download once
#so it's easy to rebuild a container without download times
packages_dir := build/packages
packages := java.rpm \
	zeppelin.tgz
packages := $(packages:%=$(packages_dir)/%)
.PRECIOUS: $(packages)

$(packages_dir):
	mkdir -p $(packages_dir)

$(packages_dir)/java.rpm: | $(packages_dir)
	curl -L \
		'http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.rpm'\
		-H 'Cookie: oraclelicense=accept-securebackup-cookie' > $@

$(packages_dir)/zeppelin.tgz: | $(packages_dir)
	curl http://www-us.apache.org/dist/zeppelin/zeppelin-0.6.0/zeppelin-0.6.0-bin-all.tgz > $@

build := build/image
build: $(build)
$(build): Dockerfile $(packages)
	mkdir -p build/
	docker build -t $(IMAGE_NAME) .
	touch $@

cid_file := build/container_id
$(cid_file): $(build) 
	docker create \
		--volumes-from hadoop_master-$(shell whoami) \
		--privileged=true \
		--pid=host \
		--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@

start: $(cid_file)
	docker start $(CONTAINER_NAME)
	#docker exec $(CONTAINER_NAME) bash -c "ifconfig eth0 | grep -oP '\d+\.\d+\.\d+\.\d+'" | head -n1 > build/ip
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME) > build/ip

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
clean_container:
	-docker rm -v $(CONTAINER_NAME) && rm $(cid_file)

clean_image:
	-docker rmi $(IMAGE_NAME) && rm $(build)

shell: 
	docker exec -it $(CONTAINER_NAME) bash


portmap: build/ip
	sudo iptables -t nat -A DOCKER -p tcp --dport 1234 -j DNAT \
		--to-destination `cat build/ip`:8080
	#sudo iptables -t nat -A DOCKER -p tcp --dport 6666 -j LOG \
		#--log-prefix "zeppelin map"
portunmap:
	sudo iptables -t nat -D DOCKER -p tcp --dport 1234 -j DNAT \
		--to-destination `cat build/ip`:8080
	#sudo iptables -t nat -D DOCKER -p tcp --dport 6666 -j LOG \
		#--log-prefix "zeppelin map"

