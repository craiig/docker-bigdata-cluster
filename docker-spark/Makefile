all: start

IMAGE_NAME := spark-$(shell whoami)
CONTAINER_NAME := spark-$(shell whoami)
DOCKER_EXEC := docker exec $(CONTAINER_NAME)

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
		--volumes-from hadoop_master-$(shell whoami) \
		--privileged=true \
	       	--name $(IMAGE_NAME) $(CONTAINER_NAME)
	echo $(CONTAINER_NAME) > $@
	docker cp $(CONTAINER_NAME):/root/.ssh/id_rsa build/id_rsa

start: $(cid_file)
	docker start $(CONTAINER_NAME)
	docker exec $(CONTAINER_NAME) bash -c "ifconfig eth0 | grep -oP '\d+\.\d+\.\d+\.\d+'" | head -n1 > build/ip

stop:
	-docker stop $(CONTAINER_NAME)

clean: stop clean_container clean_image
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

ssh: start
	ssh -o StrictHostKeyChecking=no \
	       -o UserKnownHostsFile=/dev/null \
       	       -i build/id_rsa root@`cat build/ip`

bdb-prepare-data-1node:
	hdfs dfs -rm -r -f /user/spark/benchmark
	hdfs dfs -mkdir -p /user/spark/benchmark
	hdfs dfs -put -f ../benchmark-bdb/data//text-deflate/1node/rankings /user/spark/benchmark/rankings
	hdfs dfs -put -f ../benchmark-bdb/data//text-deflate/1node/uservisits /user/spark/benchmark/uservisits
	hdfs dfs -put -f ../benchmark-bdb/data//text-deflate/1node/crawl /user/spark/benchmark/crawl
	hdfs dfs -cp /user/spark/benchmark/rankings /user/spark/benchmark/scratch

bdb-prepare-data-tiny:
	hdfs dfs -rm -r -f /user/spark/benchmark
	hdfs dfs -mkdir -p /user/spark/benchmark
	hdfs dfs -put -f ../benchmark-bdb/data//text/tiny/rankings /user/spark/benchmark/rankings
	hdfs dfs -put -f ../benchmark-bdb/data//text/tiny/uservisits /user/spark/benchmark/uservisits
	hdfs dfs -put -f ../benchmark-bdb/data//text/tiny/crawl /user/spark/benchmark/crawl
	hdfs dfs -cp /user/spark/benchmark/rankings /user/spark/benchmark/scratch

bdb-prepare-sql-tiny: start
	../benchmark-bdb/benchmark/runner/prepare-benchmark.sh \
		--spark \
		--skip-s3-import \
		--file-format=text \
		--scale-factor=1 \
		--spark-host=`cat build/ip` \
		--spark-identity-file=`pwd`/build/id_rsa \
		--aws-key-id=foo \
		--aws-key=bar

bdb-prepare-sql-1node: start
	../benchmark-bdb/benchmark/runner/prepare-benchmark.sh \
		--spark \
		--skip-s3-import \
		--file-format=text-deflate \
		--scale-factor=1 \
		--spark-host=`cat build/ip` \
		--spark-identity-file=`pwd`/build/id_rsa \
		--aws-key-id=foo \
		--aws-key=bar

bdb-run-q1a: start
	../benchmark-bdb/benchmark/runner/run-query.sh \
		--spark \
		--spark-hadoop \
		--num-trials 10 \
		--spark-host=`cat build/ip` \
		--spark-identity-file=`pwd`/build/id_rsa \
		--query-num=1a

bdb-run-q1b: start
	../benchmark-bdb/benchmark/runner/run-query.sh \
		--spark \
		--spark-hadoop \
		--num-trials 10 \
		--spark-host=`cat build/ip` \
		--spark-identity-file=`pwd`/build/id_rsa \
		--query-num=1b

#this rule has a problem because it takes a different cwd
#than via ssh - so  don't use it, it's kept here as reference
bdb-prepare-sql-cmds: start
	$(DOCKER_EXEC) spark-sql -e DROP TABLE IF EXISTS rankings; CREATE EXTERNAL TABLE rankings (pageURL STRING, pageRank INT, avgDuration INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY \",\" STORED AS TEXTFILE LOCATION \"/user/spark/benchmark/rankings\";
	echo ----- rankings done
	$(DOCKER_EXEC)  cd /root && spark-sql -e "DROP TABLE IF EXISTS scratch; CREATE EXTERNAL TABLE scratch (pageURL STRING, pageRank INT, avgDuration INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY \",\" STORED AS TEXTFILE LOCATION \"/user/spark/benchmark/scratch\";"
	echo ----- scratch done
	$(DOCKER_EXEC) cd /root && spark-sql -e "DROP TABLE IF EXISTS uservisits; CREATE EXTERNAL TABLE uservisits (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY \",\" STORED AS TEXTFILE LOCATION \"/user/spark/benchmark/uservisits\";"
	echo ----- uservisits done
	$(DOCKER_EXEC) cd /root && spark-sql -e "DROP TABLE IF EXISTS documents; CREATE EXTERNAL TABLE documents (line STRING) STORED AS TEXTFILE LOCATION \"/user/spark/benchmark/crawl\";"
	echo ----- documents done

