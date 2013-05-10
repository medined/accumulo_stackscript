#!/bin/bash

pathmunge () {
        if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH=$PATH:$1
           else
              PATH=$1:$PATH
           fi
        fi
}
pathmunge /usr/local/sbin
pathmunge /usr/local/bin
pathmunge /usr/sbin
pathmunge /usr/bin
pathmunge /sbin
pathmunge /bin
pathmunge /usr/games
pathmunge /usr/lib/jvm/java-6-openjdk/bin
pathmunge $HOME/accumulo_home/software/hadoop/bin
pathmunge $HOME/accumulo_home/software/zookeeper/bin
pathmunge $HOME/accumulo_home/bin/accumulo/bin

export BASE_DIR=$HOME/accumulo_home

export ACCUMULO_HOME=$BASE_DIR/bin/accumulo
export HADOOP_HOME=$BASE_DIR/software/hadoop
export HADOOP_PREFIX=$BASE_DIR/software/hadoop
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export ZOOKEEPER_HOME=$BASE_DIR/software/zookeeper

export HADOOP_VERSION=hadoop-1.0.4
export LOGFILE=$HOME/build.log
export PASSWORD=`openssl passwd -1 password`

mkdir -p $BASE_DIR/software $BASE_DIR/data $BASE_DIR/bin

