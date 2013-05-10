#!/bin/bash

export BASE_DIR=$HOME/accumulo_home

export ACCUMULO_HOME=$BASE_DIR/bin/accumulo
export HADOOP_HOME=$BASE_DIR/bin/hadoop
export HADOOP_PREFIX=$BASE_DIR/bin/hadoop
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export ZOOKEEPER_HOME=$BASE_DIR/bin/zookeeper

export HADOOP_VERSION=hadoop-1.0.4
export ZOOKEEPER_VERSION=zookeeper-3.4.3
export LOGFILE=$HOME/build.log
export PASSWORD=`openssl passwd -1 password`

pathmunge () {
        if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH=$PATH:$1
           else
              PATH=$1:$PATH
           fi
        fi
}
pathmunge $JAVA_HOME/bin
pathmunge $HADOOP_HOME/bin
pathmunge $ZOOKEEPER_HOME/bin
pathmunge $ACCUMULO_HOME/bin

mkdir -p $BASE_DIR/software $BASE_DIR/data $BASE_DIR/bin
