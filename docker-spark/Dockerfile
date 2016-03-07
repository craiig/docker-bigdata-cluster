FROM centos

#RUN curl http://mirror.its.dal.ca/apache/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local
COPY spark-1.6.0-bin-hadoop2.6.tgz /usr/local/
RUN tar -xzf /usr/local/spark-1.6.0-bin-hadoop2.6.tgz -C /usr/local

RUN cd /usr/local && ln -sf spark-1.6.0-bin-hadoop2.6 spark

ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

RUN yum install -y java-1.8.0-openjdk

CMD ["/bin/sh", "-c", "while true; do sleep 1000; done"]
