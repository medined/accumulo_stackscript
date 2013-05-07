#!/bin/bash

source setup.sh

CDIR=..

# install and configure zookeeper
if [ ! -f $BASE_DIR/software/zookeeper-3.4.3/conf/zoo.cfg ];
then
  tar xfz $CDIR/zookeeper-3.4.3.tar.gz -C $BASE_DIR/software
  cp $CDIR/zoo.cfg $BASE_DIR/software/zookeeper-3.4.3/conf/zoo.cfg
  ln -s $BASE_DIR/software/zookeeper-3.4.3 $BASE_DIR/software/zookeeper
  mkdir -p $BASE_DIR/data/zookeeper_tmp_dir
  chmod 777 $BASE_DIR/data/zookeeper_tmp_dir
  sed -i "s/\/zookeeper_tmp_dir/\/home\/$USER\/data\/zookeeper_tmp_dir/" $BASE_DIR/software/zookeeper/conf/zoo.cfg
fi

# start zookeeper
result=`ps faux | grep "QuorumPeerMain" | wc -l`
if [ "$result" != "2" ];
then
  pushd $BASE_DIR/software/zookeeper; ./bin/zkServer.sh start; popd
fi

echo "Installed Zookeeper"

