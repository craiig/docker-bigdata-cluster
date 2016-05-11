ifeq ($(LOCAL),1)
SPARK_SUBMIT_ARGS := 
SPARK_SHELL_ARGS := 
PROFILE_NAME := accumulo-rankings-local
export LOCAL
$(warning export local)
else
SPARK_SUBMIT_ARGS := --deploy-mode=cluster --master yarn --num-executors 10 --executor-memory=1g
SPARK_SHELL_ARGS := --master yarn --executor-memory 1g --driver-memory 1g
PROFILE_NAME := accumulo-rankings-cluster
endif

SPARK_SHELL_ARGS += --jars utils/target/scala-2.11/util_2.11-1.0.jar

shell: utils/target/scala-2.11/util_2.11-1.0.jar
	make -C util/
	spark-shell $(SPARK_SHELL_ARGS)
