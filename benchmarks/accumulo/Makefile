ifeq ($(LOCAL),1)
SPARK_SHELL_ARGS := 
export LOCAL
$(warning export local)
else
SPARK_SHELL_ARGS := --master yarn --executor-memory 2g --driver-memory 1g --num-executors 4
endif

#SPARK_SHELL_ARGS += --jars ../util/target/scala-2.11/util-assembly-1.0.jar

# util/target/scala-2.11/util-assembly-1.0.jar
shell:
	#make -C util/
	mkdir -p context1
	cd context1; spark-shell $(SPARK_SHELL_ARGS)

shell2: util/target/scala-2.11/util-assembly-1.0.jar
	make -C util/
	mkdir -p context2
	cd context2; spark-shell $(SPARK_SHELL_ARGS)
