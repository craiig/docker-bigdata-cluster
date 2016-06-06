include ../../Makefile.options

../../data/amazon_reviews/reviews_books_first_1000.json:
	make -C ../../data/amazon_reviews/ all
	ln -s ../../data/amazon_reviews/reviews_books_first_1000.json

run-kmeans: ../../data/amazon_reviews/reviews_books_first_1000.json $(TARGET)
ifdef LOCAL
	rm -rf myModelPath
else
	# Remove files that were left over from previous executions
	hdfs dfs -rm -r -f /user/root/myModelPath/data
	hdfs dfs -rm -r -f /user/root/myModelPath/metadata
	hdfs dfs -put -f reviews_books_first_1000.json /user/root/
endif
	$(SPARK_SUBMIT) --class benchKmeans $(TARGET) accumulo 172.17.0.3 root accumulo

# run-kmeans-local: $(TARGET)
# 	$(SPARK_SUBMIT_LOCAL) --class benchKmeans $(TARGET)

perf-kmeans:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-load -- make perf-kmeans2

perf-kmeans2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class benchKmeans $(TARGET) accumulo 172.17.0.3 root accumulo"

