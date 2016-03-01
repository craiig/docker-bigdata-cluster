FROM centos

USER root

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync

COPY alluxio-1.0.0-bin.tar.gz /usr/local/
RUN tar -xzf /usr/local/alluxio-1.0.0-bin.tar.gz -C /usr/local
RUN cd /usr/local && ln -sf alluxio-1.0.0 alluxio

RUN yum install -y java-1.8.0-openjdk

# passwordless ssh so alluxio can ssh to localhost
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#stop sudo from requiring a tty so it can exec via headless scripts
RUN sed -e 's/^Defaults\s*requiretty/#&/g' /etc/sudoers > /etc/sudoers_new
RUN mv /etc/sudoers_new /etc/sudoers

#configuration file
COPY run_container.sh /usr/local/alluxio/
COPY build/conf/alluxio-env.sh /usr/local/alluxio/conf/

RUN /usr/sbin/sshd && cd /usr/local/alluxio && ./bin/alluxio format
#RUN cd /usr/local/alluxio && ./bin/alluxio-start.sh local

#CMD ["/bin/sh", "-c", "trap '/usr/local/alluxio/bin/alluxio-stop.sh' SIGTERM; /usr/sbin/sshd; while true; do sleep 1000; done"]
CMD ["/usr/local/alluxio/run_container.sh"]
