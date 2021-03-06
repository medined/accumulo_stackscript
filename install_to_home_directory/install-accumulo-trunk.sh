#!/bin/bash

source ./setup.sh
export MY_ACCUMULO_VERSION=1.6.0-SNAPSHOT

echo "Connecting to apache.org. Please be patient..."

svn co https://svn.apache.org/repos/asf/accumulo/trunk $BASE_DIR/software/accumulo
echo "Cloned accumulo"

pushd $BASE_DIR/software/accumulo; mvn -DskipTests package -P assemble; popd
echo "Compiled accumulo"

# Make the lib/ext directory group writeable so that you can deply jar files there.
tar xfz $BASE_DIR/software/accumulo/assemble/target/accumulo-$MY_ACCUMULO_VERSION-bin.tar.gz -C $BASE_DIR/bin

# Compile the native libraries
#pushd $BASE_DIR/bin/accumulo-$MY_ACCUMULO_VERSION/server/src/main/c++; make; popd
#echo "Compiled navtive library"

# remove symbolic link and then create it.
rm -f $BASE_DIR/bin/accumulo
ln -s $BASE_DIR/bin/accumulo-$MY_ACCUMULO_VERSION $BASE_DIR/bin/accumulo

mkdir -p $BASE_DIR/bin/accumulo/lib/ext
mkdir -p $BASE_DIR/bin/accumulo/logs
mkdir -p $BASE_DIR/bin/accumulo/walogs

echo "Created ext, logs, and walogs directory."

cp $BASE_DIR/bin/accumulo/conf/examples/512MB/standalone/* $BASE_DIR/bin/accumulo/conf
cp accumulo-site.xml $BASE_DIR/bin/accumulo/conf/accumulo-site.xml
cp accumulo-env.sh $BASE_DIR/bin/accumulo/conf/accumulo-env.sh
hostname -f > $BASE_DIR/bin/accumulo/conf/gc
hostname -f > $BASE_DIR/bin/accumulo/conf/masters
hostname -f > $BASE_DIR/bin/accumulo/conf/monitor
hostname -f > $BASE_DIR/bin/accumulo/conf/slaves
hostname -f > $BASE_DIR/bin/accumulo/conf/tracers

echo "initializing accumulo"
$BASE_DIR/software/hadoop/bin/hadoop fs -rmr /user/accumulo/accumulo 2>/dev/null
$BASE_DIR/bin/accumulo/bin/accumulo init --clear-instance-name --instance-name instance --username root --password secret

echo "starting accumulo"
$BASE_DIR/bin/accumulo/bin/start-all.sh

