#!/bin/bash

source setup.sh

if [ -d $BASE_DIR/bin/accumulo ];
then
  $BASE_DIR/bin/accumulo/bin/stop-all.sh
fi
if [ -d $BASE_DIR/software/hadoop ];
then
  $BASE_DIR/software/hadoop/bin/stop-mapred.sh
  $BASE_DIR/software/hadoop/bin/stop-dfs.sh
fi
if [ -d $BASE_DIR/software/zookeeper ];
then
  $BASE_DIR/software/zookeeper/bin/zkServer.sh stop
fi
rm -rf $BASE_DIR/bin $BASE_DIR/data $BASE_DIR/software $BASE_DIR/.accumulo

