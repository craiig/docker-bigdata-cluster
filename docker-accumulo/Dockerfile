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


RUN yes | cp -f $ACCUMULO_HOME/conf/examples/512MB/standalone/* $ACCUMULO_HOME/conf

CMD ["/bin/sh", "-c", "while true; do speep 1000; done"]

