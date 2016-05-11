FROM centos

RUN curl http://apache.mirror.gtcomm.net/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/zookeeper-3.4.6 /usr/local/zookeeper

ADD ./conf /usr/local/zookeeper/conf

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

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java


ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh


ENV ZOOKEEPER_HOME /usr/local/zookeeper

CMD ["/etc/bootstrap.sh", "-d"]

EXPOSE 2181
