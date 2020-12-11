# Greenplum6 数据库的docker镜像制作

## 一、简介

本项目基于dockerfile制作Greenplum6 数据库单节点的集群docker镜像。

## 二、教程

### 1、镜像制作

```
git clone https://github.com/tangyibo/greenplum_docker.git
cd greenplum_docker/
sh build.sh
```

### 2、镜像测试

```
cd greenplum_docker/
sh test.sh
```

## 三、使用

```
mkdir /data/gpdb
docker run -d -p 5432:5432 -v /data/gpdb:/data  inrgihc/greenplum:6.11.1
```

说明：首次启动镜像时会初始化集群，需要耐心等待10~60秒左右，然后方可用客户端连接数据库。

| 参数名称	| 取值	| 备注说明 |
| :--: | :-- | :-- |
| 软件安装路径	| /usr/local/greenplum-db	| greenplum程序软件安装所在目录，目前无法定制配置 |
| 数据所在路径	| /data	| greenplum数据库数据安装所在目录, 该参数可在打包时定制配置 |
| Greenplum超管账号	| gpadmin	| 登录Greenplum数据库的超级管理员账号为gpadmin |
| Greenplum超管密码	| greenplum	| 登录Greenplum数据库的超级管理员gpadmin的密码 |
| 数据库连接端口	| 5432	| greenplum数据库master的连接端口号 |