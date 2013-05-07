#!/bin/bash

export ACCUMULO_VERSION=accumulo-assemble-1.6.0-SNAPSHOT
export BASE_DIR=$HOME/accumulo_home
export HADOOP_VERSION=hadoop-1.0.4
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export LOGFILE=$HOME/build.log
export PASSWORD=`openssl passwd -1 password`

##########
# enable logging. Logs both to file and screen.
exec 2>&1
exec > >(tee -a $LOGFILE)

mkdir -p $BASE_DIR/software $BASE_DIR/data $BASE_DIR/bin

