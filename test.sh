#!/bin/bash

rm -rf ./data && mkdir data
docker run -d -p 5432:5432 -v "$PWD"/data:/data  inrgihc/greenplum:6.11.1

