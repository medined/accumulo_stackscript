#!/bin/bash

source ./setup.sh
source ./stop-all.sh

CDIR=..
export ZBASE_DIR=$BASE_DIR/bin

rm -rf $ZBASE_DIR/zookeeper
rm -rf $ZBASE_DIR/$ZOOKEEPER_VERSION
rm -rf $BASE_DIR/data/zookeeper_tmp_dir
mkdir -p $BASE_DIR/data/zookeeper_tmp_dir
chmod 777 $BASE_DIR/data/zookeeper_tmp_dir

echo "Untarring $ZOOKEEPER_VERSION to $ZBASE_DIR"
tar xfz $CDIR/$ZOOKEEPER_VERSION.tar.gz -C $ZBASE_DIR
ln -s $ZBASE_DIR/$ZOOKEEPER_VERSION $ZBASE_DIR/zookeeper
cp $CDIR/zoo.cfg $ZBASE_DIR/zookeeper/conf/zoo.cfg
# Note that I use a different delimiter instead of standard slash below because I am working with directory names.
sed -i "s^/zookeeper_tmp_dir^$BASE_DIR/data/zookeeper_tmp_dir^" $ZBASE_DIR/zookeeper/conf/zoo.cfg

pushd $ZBASE_DIR/zookeeper; ./bin/zkServer.sh start; popd

echo "Installed Zookeeper"
