#!/bin/bash

source ./setup.sh
source ./stop-all.sh

rm -rf $BASE_DIR/software/hadoop
rm -rf $BASE_DIR/software/$HADOOP_VERSION
rm -rf $BASE_DIR/data/hadoop_tmp_dir

mkdir -p $BASE_DIR/software

export CDIR=..

echo "Untarring $HADOOP_VERSION to $BASE_DIR/software"
tar xfz $CDIR/$HADOOP_VERSION.tar.gz -C $BASE_DIR/software
ln -s $BASE_DIR/software/$HADOOP_VERSION $BASE_DIR/software/hadoop
cp $CDIR/core-site.xml $BASE_DIR/software/hadoop/conf/core-site.xml
cp $CDIR/hdfs-site.xml $BASE_DIR/software/hadoop/conf/hdfs-site.xml
cp $CDIR/mapred-site.xml $BASE_DIR/software/hadoop/conf/mapred-site.xml
cp $CDIR/hadoop-env.sh $BASE_DIR/software/hadoop/conf/hadoop-env.sh
cp $CDIR/generic_logger.xml $BASE_DIR/software/hadoop/conf
cp $CDIR/monitor_logger.xml $BASE_DIR/software/hadoop/conf
# Update master and slaves with the hostname
hostname -f > $BASE_DIR/software/hadoop/conf/masters
hostname -f > $BASE_DIR/software/hadoop/conf/slaves
sed -i "s/localhost/`hostname -f`/" $BASE_DIR/software/hadoop/conf/core-site.xml
# Note that I use a different delimiter instead of standard slash below because I am working with directory names.
sed -i "s^/hadoop_tmp_dir^`echo $BASE_DIR`/data/hadoop_tmp_dir^" $BASE_DIR/software/hadoop/conf/core-site.xml
sed -i "s/localhost/`hostname -f`/" $BASE_DIR/software/hadoop/conf/mapred-site.xml

# Create the hadoop temp directory. It should not be in the /tmp directory because that directory
# disappears after each system restart. Something that is done a lot with virtual machines.
mkdir -p $BASE_DIR/data/hadoop_tmp_dir
chmod 755 $BASE_DIR/data//hadoop_tmp_dir
##########
$BASE_DIR/software/hadoop/bin/hadoop namenode -format

##########
$BASE_DIR/software/hadoop/bin/start-dfs.sh
# this creates /home/$USER directory in HDFS.
$BASE_DIR/software/hadoop/bin/start-mapred.sh

$BASE_DIR/software/hadoop/bin/hadoop fs -mkdir /user/$USER
$BASE_DIR/software/hadoop/bin/hadoop fs -mkdir /user/accumulo

echo "Installed Hadoop"
echo "View http://localhost:50070 for Name Node monitor."
echo "View http://localhost:50030 for Job Tracker monitor."

