include ../Makefile.options

SPARK_UTILS_JAR := $(ROOT)/spark-utils/target/scala-2.11/util-assembly-1.0.jar

$(SPARK_UTILS_JAR):
		make -C $(ROOT)/spark-utils all

