#!/bin/bash
############################################
# Function :  Greenplum单机一键安装脚本
# Author : tang
# Date : 2020-12-09
#
# Usage: sh install.sh
#
############################################

# GPDB的RPM包版本
GPDBVER=6.11.1
# 账号密码
PASSWORD=greenplum

# 日志等级
ERROR_MSG="[ERROR] "
INFO_MSG="[INFO] "

# 日志函数
function log() {
    TIME=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIME $1"
}

# 利用yum安装依赖包函数
function package_install() {
  log "$INFO_MSG check command package : [ $1 ]"
  if ! rpm -qa | grep -q "^$1"; then
    yum install -y $1
    package_check_ok
  else
    log "$INFO_MSG command [ $1 ] already installed."
  fi
}

# 检查命令是否执行成功
function package_check_ok() {
  ret=$?
  if [ $ret != 0 ]; then
    log "$ERROR_MSG Install failed, error code is $ret, Check the error log."
    exit 1
  fi
}

function gpdb_install(){
    log "$INFO_MSG Start to install greenplum for single node."

    # 安装依赖包
    package=(epel-release wget)
    for p in ${package[@]}; do
        package_install $p
    done

    # 创建用户与用户组
    /usr/sbin/groupadd gpadmin
    /usr/sbin/useradd gpadmin -g gpadmin
    usermod -G gpadmin gpadmin
    echo "${PASSWORD}" | passwd --stdin gpadmin

    # ssh配置
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i -r 's/^.*StrictHostKeyChecking\s+\w+/StrictHostKeyChecking no/' /etc/ssh/ssh_config
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    systemctl restart sshd

    # gpadmin账号的免密配置
    su gpadmin -l -c "ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P \"\""
    su gpadmin -l -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
    su gpadmin -l -c "chmod 600 ~/.ssh/authorized_keys" && \
    su gpadmin -l -c "ssh-keyscan -H localhost 2>/dev/null | grep rsa | awk '{print \"localhost \" \$2 \" \" \$3 }' >> ~/.ssh/known_hosts"

    # 安装greenplum的RPM包
    wget "https://github.com.cnpmjs.org/greenplum-db/gpdb/releases/download/$GPDBVER/greenplum-db-$GPDBVER-rhel7-x86_64.rpm"
    yum install -y "./greenplum-db-$GPDBVER-rhel7-x86_64.rpm"
    rm -rf "./greenplum-db-$GPDBVER-rhel7-x86_64.rpm"

    # 初始化集群并修改配置
    rm -f /home/gpadmin/gpinitsystem_config_singlenode
    cat > /home/gpadmin/gpinitsystem_config_singlenode << EOF
ARRAY_NAME="Greenplum Data Platform"
SEG_PREFIX=gpseg
PORT_BASE=6000
declare -a DATA_DIRECTORY=($DATADIR/primary $DATADIR/primary $DATADIR/primary $DATADIR/primary)
MASTER_HOSTNAME=localhost
MASTER_DIRECTORY=$DATADIR/master
MASTER_PORT=5432
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UNICODE
EOF
cat > /home/gpadmin/gp_hosts_list << EOF
localhost
EOF
cat > /home/gpadmin/initdb_gpdb.sql << EOF
ALTER ROLE "gpadmin" WITH PASSWORD '$PASSWORD';
EOF
    chown -R gpadmin:gpadmin /home/gpadmin

    log "$INFO_MSG Install single node Greenplum cluster success!"
}

# 安装操作
gpdb_install