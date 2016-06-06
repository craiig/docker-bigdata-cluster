ifeq ($(LOCAL),1)
SPARK_SUBMIT_ARGS :=
PROFILE_NAME := accumulo-rankings-local
export LOCAL
$(warning export local)
else
SPARK_SUBMIT_ARGS := --deploy-mode=cluster --master yarn --num-executors 10 --executor-memory=1g
# SPARK_SUBMIT_ARGS_LOCAL := --master local[4]
PROFILE_NAME := accumulo-rankings-cluster
endif

ifdef LOCAL
# override the local environment while make is running:
export HADOOP_CONF_DIR=""
SPARK_SUBMIT_ARGS := --master local[$(LOCAL)]
endif

SPARK_SUBMIT := spark-submit $(SPARK_SUBMIT_ARGS)
# SPARK_SUBMIT_LOCAL := spark-submit $(SPARK_SUBMIT_ARGS_LOCAL)

setup_virtualenv:
	# TODO: setting up the environment probably needs to be put somewhere else
	sudo apt-get install python-dev
	sudo apt-get install python-virtualenv
	(bash -c "source venv/bin/activate")
	pip install -r requirements.txt

run-kmeans: setup_virtualenv
ifdef LOCAL
	rm -rf myModelPath
else
	# Remove files that were left over from previous executions
	hdfs dfs -rm -r -f /user/root/myModelPath/data
	hdfs dfs -rm -r -f /user/root/myModelPath/metadata
	hdfs dfs -put -f kmeans_data.txt
endif
	$(SPARK_SUBMIT) kmeans.py
