ifeq ($(LOCAL),1)
SPARK_SHELL_ARGS := 
export LOCAL
$(warning export local)
else
SPARK_SHELL_ARGS := --master yarn --executor-memory 2g --driver-memory 2g --num-executors 10
endif

SPARK_SHELL_ARGS += --jars utils/target/scala-2.11/util_2.11-1.0.jar

shell: utils/target/scala-2.11/util_2.11-1.0.jar
	make -C utils/
	spark-shell $(SPARK_SHELL_ARGS)
