#!/bin/bash

source setup.sh

CDIR=..

# install and configure hadoop
if [ ! -f $BASE_DIR/software/$HADOOP_VERSION/conf/core-site.xml ];
then
  tar xfz $CDIR/$HADOOP_VERSION.tar.gz -C $BASE_DIR/software
  rm -f $BASE_DIR/software/hadoop
  ln -s $HADOOP_VERSION hadoop
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
  sed -i "s/\/hadoop_tmp_dir/\/home\/$USER\/data\/hadoop_tmp_dir/" $BASE_DIR/software/hadoop/conf/core-site.xml
  sed -i "s/localhost/`hostname -f`/" $BASE_DIR/software/hadoop/conf/mapred-site.xml
fi

# Create the hadoop temp directory. It should not be in the /tmp directory because that directory
# disappears after each system restart. Something that is done a lot with virtual machines.
mkdir -p /home/$USER/data/hadoop_tmp_dir
chmod 755 /home/$USER/data//hadoop_tmp_dir
##########
# format hadoop, if needed
if [ ! -d /home/$USER/data/hadoop_tmp_dir/dfs/name ];
then
  $BASE_DIR/software/hadoop/bin/hadoop namenode -format
fi

##########
# If hadoop is not running, then format the namenode and start hadoop.
result=`ps faux | grep "proc_namenode" | wc -l`
if [ "$result" != "2" ];
then
  $BASE_DIR/software/hadoop/bin/start-dfs.sh
  # this creates /home/$USER directory in HDFS.
  $BASE_DIR/software/hadoop/bin/start-mapred.sh
fi

##########
# Create an hadoop user directory if needed. This is the HDFS default
# directory for the user.
result=`$BASE_DIR/software/hadoop/bin/hadoop fs -ls /user 2>/dev/null | grep $USER | wc -l`
if [ "$result" == "0" ];
then
  $BASE_DIR/software/hadoop/bin/hadoop fs -mkdir /user/$USER
fi

##########
# Create an accumulo hdfs directory if needed. This is the
# HDFS directory for accumulo.
result=`$BASE_DIR/software/hadoop/bin/hadoop fs -ls /user 2>/dev/null | grep accumulo | wc -l`
if [ "$result" == "0" ];
then
  $BASE_DIR/software/hadoop/bin/hadoop fs -mkdir /user/accumulo
fi


echo "Installed Hadoop"
echo "View http://localhost:50070 for Name Node monitor."
echo "View http://localhost:50030 for Job Tracker monitor."

