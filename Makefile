all:

start:
	#start hadoop master
	make -C docker-hadoop start
	#generate a config (docker container needs to be running)
	make -C ./hadoop-config-gen clean all install

stop:
	-make -C docker-hadoop stop
	-make -C hadoop-config-gen clean
	-make -C docker-spark stop

clean:
	make -C docker-hadoop stop clean
	make -C docker-spark stop clean

docker-hadoop/build/hostname:
	make -C docker-hadoop build/hostname
	#docker run with host network - will this expose them directly?
	#docker run -d hadoop "/etc/bootstrap.sh" -d > $@
	#docker run --net=host -d hadoop "/etc/bootstrap.sh" -d > $@
	#docker run with open ports: (except these are renaomdly remapped??)
	#docker run -d -P hadoop /etc/bootstrap.sh -d

#old rules
clean_docker:
	# Delete all containers and their volumes
	-docker rm -v $(shell docker ps -a -q)
	# Delete all images
	-docker rmi $(shell docker images -q)	
