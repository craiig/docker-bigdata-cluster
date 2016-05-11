FROM centos
# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y net-tools which; \
	yum groupinstall -y "Development Tools"

RUN curl http://apache.parentingamerica.com/accumulo/1.7.1/accumulo-1.7.1-bin.tar.gz | tar -xz -C /usr/local/

RUN cd /usr/local && ln -sf accumulo-1.7.1 accumulo

# oracle java
COPY build/packages/java.rpm .
RUN rpm -i java.rpm
RUN rm java.rpm

#support perf-map-agent to get symbols from java JIT
# pulling from git because relative paths in dockerfile COPY don't work
RUN yum install -y git cmake gcc-c++
RUN cd ~/ && git clone --depth=1 https://github.com/craiig/perf-map-agent
#COPY perf-map-agent /root/perf-map-agent #use this line when testing perf-map-agent before pushing to git
RUN cd ~/perf-map-agent/ && JAVA_HOME=/usr/java/default/ cmake . && make
ENV JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so"
RUN echo "export JAVA_TOOL_OPTIONS=\"-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so\"" >> ~/.bash_profile

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

ENV ACCUMULO_HOME /usr/local/accumulo
ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV HADOOP_PREFIX /usr/local/hadoop
ENV PATH $PATH:/usr/local/accumulo/bin:/usr/local/hadoop/bin:/usr/local/zookeeper/bin

#setup configuration
ADD accumulo-conf/ $ACCUMULO_HOME/conf/
ADD out/* $ACCUMULO_HOME/conf/

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

RUN $ACCUMULO_HOME/bin/build_native_library.sh

CMD ["/etc/bootstrap.sh", "-d"]


# 2181 Zookeeper, 2888 Zookeeper, 3888 Zookeeper
# EXPOSE 2181 2888 3888

# 4560 Accumulo monitor, 11224 Accumulo Logger, 12234 Accumulo Tracer, 50095 Accumulo HTTP monitor
EXPOSE 4560 11224 12234 50095

# 9000 HDFS, 9001 JobTracker, 9997 Tablet Server, 9999 Master Server, 50010 DataNode Data, 50020 DataNode Metadata, 50060 TaskTrackers, 50070 NameNode HTTP monitor, 50075 DataNode HTTP monitor
EXPOSE 9000 9001 9997 9999 50010 50020 50060 50070 50075

# 50091 appears to be for the the garbage collector
EXPOSE 50091
