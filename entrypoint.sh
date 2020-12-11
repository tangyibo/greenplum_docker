#!/bin/bash
############################################
# Function :  EntryPoint入口
# Author : tang
# Date : 2020-12-09
#
# Usage: sh entrypoint.sh
#
############################################

# 启动ssh服务
/var/run/sshd/sshd_start.sh && sleep 5s

if [ "`ls -A $DATADIR`" = "" ]; then
    # 创建数据库存放目录
    mkdir -p $DATADIR/master
    mkdir -p $DATADIR/primary
    chown -R gpadmin:gpadmin $DATADIR

    # 设置gpadmin账号的环境变量
    su - gpadmin -l -c "echo -e 'source /usr/local/greenplum-db/greenplum_path.sh' >> ~/.bashrc"
    su - gpadmin -l -c "echo -e 'export MASTER_DATA_DIRECTORY=$DATADIR/master/gpseg-1/' >> ~/.bashrc"
    su - gpadmin -l -c "echo -e 'export PGPORT=5432' >> ~/.bashrc"
    su - gpadmin -l -c "echo -e 'export PGUSER=gpadmin' >> ~/.bashrc"
    su - gpadmin -l -c "echo -e 'export PGDATABASE=postgres' >> ~/.bashrc"

    # 启动数据库集群
    su - gpadmin -l -c "source ~/.bashrc;gpinitsystem -a --ignore-warnings -c /home/gpadmin/gpinitsystem_config_singlenode -h /home/gpadmin/gp_hosts_list"
    su - gpadmin -l -c "source ~/.bashrc;psql -d postgres -U gpadmin -f /home/gpadmin/initdb_gpdb.sql"
    su - gpadmin -l -c "source ~/.bashrc;gpconfig -c log_statement -v none"
    su - gpadmin -l -c "source ~/.bashrc;gpconfig -c gp_enable_global_deadlock_detector -v on"
    su - gpadmin -l -c "echo \"host  all  all  0.0.0.0/0  password\" >> $DATADIR/master/gpseg-1/pg_hba.conf"
    su - gpadmin -l -c "source ~/.bashrc && sleep 5s && gpstop -u && tail -f gpAdminLogs/*.log"
else
    su - gpadmin -l -c "source ~/.bashrc && gpstart -a && tail -f gpAdminLogs/*.log"
fi
