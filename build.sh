#!/bin/bash
############################################
# Function :  Docker镜像制作脚本
# Author : tang
# Date : 2020-12-09
#
# Usage: sh build.sh
#
############################################

docker build -t inrgihc/greenplum:6.11.1 .
