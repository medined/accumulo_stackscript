#!/bin/bash

source ./setup.sh
source ./stop-all.sh

export CDIR=..
# define the location to install hadoop.
export HBASE_DIR=$BASE_DIR/bin

rm -rf $HBASE_DIR/hadoop
rm -rf $HBASE_DIR/$HADOOP_VERSION
rm -rf $BASE_DIR/data/hadoop_tmp_dir
mkdir -p $HBASE_DIR
mkdir -p $BASE_DIR/data/hadoop_tmp_dir
chmod 755 $BASE_DIR/data/hadoop_tmp_dir

echo "Untarring $HADOOP_VERSION to $HBASE_DIR"
tar xfz $CDIR/$HADOOP_VERSION.tar.gz -C $HBASE_DIR
ln -s $HBASE_DIR/$HADOOP_VERSION $HBASE_DIR/hadoop
cp $CDIR/core-site.xml $HBASE_DIR/hadoop/conf/core-site.xml
cp $CDIR/hdfs-site.xml $HBASE_DIR/hadoop/conf/hdfs-site.xml
cp $CDIR/mapred-site.xml $HBASE_DIR/hadoop/conf/mapred-site.xml
cp $CDIR/hadoop-env.sh $HBASE_DIR/hadoop/conf/hadoop-env.sh
cp $CDIR/generic_logger.xml $HBASE_DIR/hadoop/conf
cp $CDIR/monitor_logger.xml $HBASE_DIR/hadoop/conf
# Update master and slaves with the hostname
hostname -f > $HBASE_DIR/hadoop/conf/masters
hostname -f > $HBASE_DIR/hadoop/conf/slaves
sed -i "s/localhost/`hostname -f`/" $HBASE_DIR/hadoop/conf/core-site.xml
# Note that I use a different delimiter instead of standard slash below because I am working with directory names.
sed -i "s^/hadoop_tmp_dir^$BASE_DIR/data/hadoop_tmp_dir^" $HBASE_DIR/hadoop/conf/core-site.xml
sed -i "s/localhost/`hostname -f`/" $HBASE_DIR/hadoop/conf/mapred-site.xml

$HBASE_DIR/hadoop/bin/hadoop namenode -format

##########
$HBASE_DIR/hadoop/bin/start-dfs.sh

$HBASE_DIR/hadoop/bin/hadoop fs -mkdir /user/$USER
$HBASE_DIR/hadoop/bin/hadoop fs -mkdir /user/accumulo

$HBASE_DIR/hadoop/bin/stop-dfs.sh

