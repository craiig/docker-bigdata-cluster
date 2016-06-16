include ../../Makefile.options

../../data/amazon_reviews/reviews_books_first_1000.json:
	make -C ../../data/amazon_reviews/ all

run-kmeans: ../../data/amazon_reviews/reviews_books_first_1000.json
ifeq ($(SPARK_MODE), local)
	ln -s ../../data/amazon_reviews/reviews_books_first_1000.json
else
	hdfs dfs -put -f ../../data/amazon_reviews/reviews_books_first_1000.json /user/root/
endif
	$(SPARK_SUBMIT) kmeans.py reviews_books_first_1000.json

# Do this manually when needed
load-big-data: /mnt/scratch/benchmark_data/amazon_reviews/
	hdfs dfs -mkdir -p /user/root/amazon_reviews/
	hdfs dfs -put /mnt/scratch/benchmark_data/amazon_reviews/* /user/root/amazon_reviews/

run-kmeans-big:
	$(SPARK_SUBMIT) kmeans.py /user/root/amazon_reviews
