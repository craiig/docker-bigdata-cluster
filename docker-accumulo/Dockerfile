FROM centos

RUN curl http://apache.mirror.vexxhost.com/accumulo/1.7.0/accumulo-1.7.0-bin.tar.gz | tar -xz -C /usr/local/

RUN cd /usr/local && ln -sf accumulo-1.7.0 accumulo

RUN yum install -y java-1.8.0-openjdk

ENV ACCUMULO_HOME /usr/local/accumulo
ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV HADOOP_PREFIX /usr/local/hadoop
