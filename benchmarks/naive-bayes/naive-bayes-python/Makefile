include ../../Makefile.options

../../data/emails/CSDMC2010_SPAM/CSDMC2010_SPAM:
	make -C ../../data/emails/ all

run-spam-filter: ../../data/emails/CSDMC2010_SPAM/CSDMC2010_SPAM
	hdfs dfs -put -f ../../data/emails/CSDMC2010_SPAM/CSDMC2010_SPAM /user/root/
	$(SPARK_SUBMIT) spam_filter.py
