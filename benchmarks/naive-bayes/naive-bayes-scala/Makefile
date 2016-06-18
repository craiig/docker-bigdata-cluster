include ../../Makefile.options

#TARGET:=./target/scala-2.11/kmeans-assembly-1.0.jar
TARGET:=./target/scala-2.11/naive-bayes_2.11-1.0.jar

all: $(TARGET)
$(TARGET): ./naive-bayes.scala ./naive-bayes.sbt
	#sbt assembly
	sbt package

clean:
	sbt clean

../../data/amazon_reviews/reviews_books_first_1000.json:
	make -C ../../data/amazon_reviews/ all
	ln -s ../../data/amazon_reviews/reviews_books_first_1000.json

run-naive-bayes: ../../data/amazon_reviews/reviews_books_first_1000.json $(TARGET)
ifdef LOCAL
	rm -rf myModelPath
else
	# Remove files that were left over from previous executions
	hdfs dfs -rm -r -f /user/root/myModelPath/data
	hdfs dfs -rm -r -f /user/root/myModelPath/metadata
	hdfs dfs -put -f ../../data/amazon_reviews/reviews_books_first_1000.json /user/root/
endif
	$(SPARK_SUBMIT) --class benchNaiveBayes $(TARGET) /user/root/reviews_books_first_1000.json


load-big-data: /mnt/scratch/benchmark_data/amazon_reviews/
	hdfs dfs -mkdir -p /user/root/amazon_reviews/
	hdfs dfs -put /mnt/scratch/benchmark_data/amazon_reviews/* /user/root/amazon_reviews/

run-naive-bayes-big: $(TARGET)
	$(SPARK_SUBMIT) --class benchNaiveBayes $(TARGET) /user/root/amazon_reviews

# run-kmeans-local: $(TARGET)
# 	$(SPARK_SUBMIT_LOCAL) --class benchKmeans $(TARGET)

perf-kmeans:
	sudo ../../profiler/profiler.sh $(PROFILE_NAME)-load -- make perf-kmeans2

perf-kmeans2:
	sudo -u cam14 bash -c "source ../../local-hadoop/source.sh && ../../local-hadoop/spark/bin/spark-submit $(SPARK_SUBMIT_ARGS) --class benchKmeans $(TARGET) accumulo 172.17.0.3 root accumulo"

