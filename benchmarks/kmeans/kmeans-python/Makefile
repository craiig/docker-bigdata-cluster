include ../../Makefile.options

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
	hdfs dfs -put -f ../../data/amazon_reviews/reviews_books_first_1000.json /user/root/
endif
	$(SPARK_SUBMIT) kmeans.py reviews_books_first_1000.json
