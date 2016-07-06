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
RUN yum install -y git cmake gcc-c++
RUN cd ~/ && git clone --depth=1 https://github.com/craiig/perf-map-agent
#COPY perf-map-agent /root/perf-map-agent #use this line when testing perf-map-agent before pushing to git
RUN cd ~/perf-map-agent/ && JAVA_HOME=/usr/java/default/ cmake . && make
ENV JAVA_TOOL_OPTIONS="-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so"
RUN echo "export JAVA_TOOL_OPTIONS=\"-XX:+PreserveFramePointer -agentpath:/root/perf-map-agent/out/libperfmap.so\"" >> ~/.bash_profile

#RUN curl http://mirror.its.dal.ca/apache/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local
COPY ./build/packages/spark-1.6.1-bin-hadoop2.6.tgz /usr/local/
RUN tar -xzf /usr/local/spark-1.6.1-bin-hadoop2.6.tgz -C /usr/local

RUN cd /usr/local && ln -sf spark-1.6.1-bin-hadoop2.6 spark

COPY run_container.sh /usr/local/spark/

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#hadoop configuration
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

#put it in the ssh conig too
RUN echo "export HADOOP_PREFIX=/usr/local/hadoop" >> ~/.bash_profile
RUN echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" >> ~/.bash_profile
RUN echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" >> ~/.bash_profile
RUN echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> ~/.bash_profile
RUN echo "export HADOOP_YARN_HOME=/usr/local/hadoop" >> ~/.bash_profile
RUN echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop" >> ~/.bash_profile
RUN echo "export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> ~/.bash_profile

#support berkeley big data bench spark variant
# by replacing some paths
RUN ln -sf /usr/local/spark /root/spark
ENV PATH $PATH:/usr/local/hadoop/bin:/usr/local/spark/bin
RUN echo "export PATH=\$PATH:/usr/local/hadoop/bin:/usr/local/spark/bin" >> /root/.bash_profile
#commented out for now to test the oracle jdk
#RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /root/.bash_profile
#RUN mkdir -p /usr/java/ && ln -sf /usr/lib/jvm/jre /usr/java/default
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

EXPOSE 22
#CMD ["/bin/sh", "-c", "while true; do sleep 1000; done"]
CMD ["/usr/local/spark/run_container.sh"]
