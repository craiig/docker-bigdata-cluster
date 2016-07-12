FROM centos
#
# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y openssh-server openssh-clients net-tools which

# oracle java
COPY build/packages/java.rpm .
RUN rpm -i java.rpm
RUN rm java.rpm

#support perf-map-agent to get symbols from java JIT
# pulling from git because relative paths in dockerfile COPY don't work
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y git cmake gcc-c++ net-tools
RUN cd ~/ && git clone --depth=1 https://github.com/craiig/perf-map-agent
#COPY perf-map-agent /root/perf-map-agent #use this line when testing perf-map-agent before pushing to git
RUN cd ~/perf-map-agent/ && JAVA_HOME=/usr/java/default/ cmake . && make
ENV JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so"
RUN echo "export JAVA_TOOL_OPTIONS=\"-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so\"" >> ~/.bash_profile

COPY ./build/packages/zeppelin.tgz /usr/local/
RUN mkdir /usr/local/zeppelin && tar -xzf /usr/local/zeppelin.tgz -C /usr/local/zeppelin --strip-components=1

COPY run_container.sh /usr/local/zeppelin/

#hadoop configuration
#ENV HADOOP_PREFIX /usr/local/hadoop
#ENV HADOOP_COMMON_HOME /usr/local/hadoop
#ENV HADOOP_HDFS_HOME /usr/local/hadoop
#ENV HADOOP_MAPRED_HOME /usr/local/hadoop
#ENV HADOOP_YARN_HOME /usr/local/hadoop
#ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
#ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

#put it in the ssh conig too
#RUN echo "export HADOOP_PREFIX=/usr/local/hadoop" >> ~/.bash_profile
#RUN echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" >> ~/.bash_profile
#RUN echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" >> ~/.bash_profile
#RUN echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> ~/.bash_profile
#RUN echo "export HADOOP_YARN_HOME=/usr/local/hadoop" >> ~/.bash_profile
#RUN echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop" >> ~/.bash_profile
#RUN echo "export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> ~/.bash_profile
#ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

#CMD ["/bin/sh", "-c", "while true; do sleep 1000; done"]
EXPOSE 8080
CMD ["/usr/local/zeppelin/run_container.sh"]
