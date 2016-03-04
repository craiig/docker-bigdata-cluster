FROM centos

RUN curl http://apache.mirror.gtcomm.net/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/zookeeper-3.4.6 /usr/local/zookeeper

ADD ./conf /usr/local/zookeeper/conf

RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-7u71-linux-x64.rpm
RUN rm jdk-7u71-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java


ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh


ENV ZOOKEEPER_HOME /usr/local/zookeeper

CMD ["/etc/bootstrap.sh", "-d"]

EXPOSE 2181
