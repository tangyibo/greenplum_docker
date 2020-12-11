FROM centos:centos7

# Greenplum的数据存放目录
ENV DATADIR=/data

# 文件准备
COPY install.sh /tmp/install.sh
COPY entrypoint.sh /entrypoint.sh

# 执行按照
RUN yum -y install passwd openssl openssh-server  openssh-clients &&\
    mkdir  /var/run/sshd/ &&\
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    echo -e '#!/bin/bash\n/usr/sbin/sshd -D &' > /var/run/sshd/sshd_start.sh && \
    chmod u+x /var/run/sshd/sshd_start.sh

RUN /var/run/sshd/sshd_start.sh && \
    sleep 10s && cd /tmp && sh install.sh && \
    rm -rf /tmp/install.sh && rm -rf /tmp/files

# 暴露端口
EXPOSE 5432 22

USER  root

CMD  [ "sh" , "/entrypoint.sh"]
