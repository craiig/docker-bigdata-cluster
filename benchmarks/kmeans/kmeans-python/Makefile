ifeq ($(LOCAL),1)
SPARK_SUBMIT_ARGS :=
export LOCAL
$(warning export local)
else
SPARK_SUBMIT_ARGS := --deploy-mode=cluster --master yarn --num-executors 10 --executor-memory=1g
endif

ifdef LOCAL
# override the local environment while make is running:
export HADOOP_CONF_DIR=""
SPARK_SUBMIT_ARGS := --master local[$(LOCAL)]
endif

SPARK_SUBMIT := spark-submit $(SPARK_SUBMIT_ARGS)

setup_virtualenv:
	# TODO: setting up the environment probably needs to be put somewhere else
	sudo apt-get install python-dev
	sudo apt-get install python-virtualenv
	sudo apt-get install python-numpy

run-kmeans: setup_virtualenv
ifdef LOCAL
	rm -rf myModelPath
else
	# Remove files that were left over from previous executions
	hdfs dfs -rm -r -f /user/root/myModelPath/
	hdfs dfs -put -f reviews_books_first_1000.json
endif
	$(SPARK_SUBMIT) kmeans.py reviews_books_first_1000.json
