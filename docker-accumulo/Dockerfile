FROM centos

RUN curl http://apache.parentingamerica.com/accumulo/1.7.1/accumulo-1.7.1-bin.tar.gz | tar -xz -C /usr/local/

RUN cd /usr/local && ln -sf accumulo-1.7.1 accumulo

RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-7u71-linux-x64.rpm
RUN rm jdk-7u71-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

ENV ACCUMULO_HOME /usr/local/accumulo
ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV HADOOP_PREFIX /usr/local/hadoop
ENV PATH $PATH:/usr/local/accumulo/bin:/usr/local/hadoop/bin:/usr/local/zookeeper/bin

#setup configuration
RUN yes | cp -f $ACCUMULO_HOME/conf/examples/512MB/standalone/* $ACCUMULO_HOME/conf
ADD out/* $ACCUMULO_HOME/conf/



ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]


# 2181 Zookeeper, 2888 Zookeeper, 3888 Zookeeper
# EXPOSE 2181 2888 3888

# 4560 Accumulo monitor, 11224 Accumulo Logger, 12234 Accumulo Tracer, 50095 Accumulo HTTP monitor
EXPOSE 4560 11224 12234 50095

# 9000 HDFS, 9001 JobTracker, 9997 Tablet Server, 9999 Master Server, 50010 DataNode Data, 50020 DataNode Metadata, 50060 TaskTrackers, 50070 NameNode HTTP monitor, 50075 DataNode HTTP monitor
EXPOSE 9000 9001 9997 9999 50010 50020 50060 50070 50075

# 50091 appears to be for the the garbage collector
EXPOSE 50091
