#A basic install of hadoop for controlling stuff locally

include ../Makefile.options

all: hadoop spark run_templates

run_templates: spark/conf/spark-defaults.conf

spark/conf/spark-defaults.conf: ./templates/spark-defaults.conf ../docker-hadoop/build/hostname
	sed s/{{MASTER}}/${HADOOP_MASTER_HOSTNAME}/g $< > $@

hadoop-2.7.1.tar.gz:
	wget http://mirror.its.dal.ca/apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz 

hadoop: hadoop-2.7.1.tar.gz
	mkdir -p hadoop
	tar -vzxf $< -C hadoop --strip-components=1

spark-1.6.1-bin-hadoop2.6.tgz:
	wget http://mirror.its.dal.ca/apache/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz

spark: spark-1.6.1-bin-hadoop2.6.tgz
	mkdir -p $@
	tar -vzxf $< -C $@ --strip-components=1

jdk-8u77-linux-x64.tar.gz:
	curl -L \
		'http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.tar.gz'\
		-H 'Cookie: oraclelicense=accept-securebackup-cookie' > $@

#don't run this unless you know what you're doing
# this adds the oracle JDK to the standard place where it's found on CentoS docker vms
# this is primarily to help with symbol mapping, not running java, but we'll see
java-install:
	mkdir -p /usr/java/jdk1.8.0_77/
	cp -R java/* /usr/java/jdk1.8.0_77/

java: jdk-8u77-linux-x64.tar.gz
	mkdir -p $@
	tar -vzxf $< -C $@ --strip-components=1

-include ../benchmarks/Makefile.options
-include ../spark-utils/sparkutils.mk
SPARK_SHELL_ARGS := --master yarn --executor-memory 4g --driver-memory 1g --num-executors 2 \
	--conf spark.eventLog.enabled=true \
	--conf spark.logLineage=true \
	--conf spark.cleaner.referenceTracking=false \
	--conf spark.profiling.dir="/root/profiler/" \
	--conf spark.profiling.sampleStacks=true \
	--conf spark.executorEnv.JAVA_TOOL_OPTIONS="-agentpath:/root/profiler/liblagent.so=start=0"
	#--conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
	#--conf spark.executorEnv.JAVA_TOOL_OPTIONS="-agentpath:/root/profiler/mtrace.so"
	#--conf spark.profiling.dir="/root/profiler/" \
	#--conf spark.executorEnv.JAVA_TOOL_OPTIONS=""
	#--conf spark.executorEnv.JAVA_TOOL_OPTIONS="-agentpath:/root/profiler/liblagent.so=start=0 -agentpath:/root/profiler/jvm-method-trace.so"

	#--conf spark.profiling.sampleStacks=true \
	# --conf spark.yarn.appMasterEnv.JAVA_TOOL_OPTIONS="-agentpath:/root/yourkit/bin/linux-x86-64/libyjpagent.so" \
	#--conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
#--conf spark.authenticate=true

SPARK_SHELL_ARGS_LIMITED := --master yarn --executor-memory 2g --driver-memory 1g --num-executors 1 \
	--conf spark.eventLog.enabled=true \
	--conf spark.logLineage=true 
	#--conf spark.serializer=org.apache.spark.serializer.KryoSerializer

spark-shell: all $(SPARK_UTILS_JAR)
	#docker cp ../java-profiler/jvm-method-trace/build/jvm-method-trace.so hadoop_master-$(shell whoami):/root/profiler/
	#docker cp ../java-profiler/jvm-method-trace/build/mtrace.so hadoop_master-$(shell whoami):/root/profiler/
	#docker cp ../java-profiler/jvm-method-trace/java/target/jvm-method-trace-1.0.jar hadoop_master-$(shell whoami):/usr/java/jdk1.8.0_77/jre/demo/jvmti/mtrace/mtrace.jar
	mkdir -p shell-context1
	cd shell-context1; spark-shell $(SPARK_SHELL_ARGS) --jars $(SPARK_UTILS_JAR),

spark-shell2: all $(SPARK_UTILS_JAR)
	docker cp ../java-profiler/jvm-method-trace/build/jvm-method-trace.so hadoop_master-$(shell whoami):/root/profiler/
	docker cp ../java-profiler/jvm-method-trace/build/mtrace.so hadoop_master-$(shell whoami):/root/profiler/
	mkdir -p shell-context2
	cd shell-context2; spark-shell $(SPARK_SHELL_ARGS) --jars $(SPARK_UTILS_JAR)

spark-shell2-limited:
	mkdir -p shell-context2
	cd shell-context2; spark-shell $(SPARK_SHELL_ARGS_LIMITED) --jars $(SPARK_UTILS_JAR)

spark-shell-local: $(SPARK_UTILS_JAR)
	./spark-shell-local.sh $@
