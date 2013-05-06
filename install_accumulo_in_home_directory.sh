#!/bin/bash

echo "You are about to install software into your HOME directory. You must have SUDO"
echo "privileges! If you don't exit this script (^c) and get them."
echo ""
echo "SUDO Use:"
echo "  copy a file to /etc/profile.d"
echo "  changing swappiness"
echo "  adding supergroup for hadoop"
echo "  installing software via apt-get"
echo ""
echo "Ignore messages about HADOOP_HOME being deprecated."
echo ""
echo "Press <ENTER> to continue> "
read

$HOME/bin/accumulo/bin/stop-all.sh
$HOME/software/hadoop/bin/stop-mapred.sh
$HOME/software/hadoop/bin/stop-dfs.sh
$HOME/software/zookeeper/bin/zkServer.sh stop
rm -rf $HOME/bin $HOME/data $HOME/software $HOME/.accumulo

export ACCUMULO_VERSION=accumulo-assemble-1.6.0-SNAPSHOT
export HADOOP_VERSION=hadoop-1.0.4
export CDIR=`pwd`
export LOGFILE=$HOME/build.log
export PASSWORD=`openssl passwd -1 password`

##########
# enable logging. Logs both to file and screen. 
exec 2>&1
exec > >(tee -a $LOGFILE)


##########
# Before this script is called have your system do:
#
# apt-get -y install git
# git clone https://github.com/medined/accumulo_stackscript.git

if [ ! -f sysctl.conf ];
then
  echo "PLEASE USE git clone to get the whole project from github."
  exit
fi

echo "- START ------------"
date +"%Y/%m/%d %H:%M:%S"

##########
# Setup environment variables when a user logs in.
#sudo cp $CDIR/login_startup.sh /etc/profile.d
#source /etc/profile.d/login_startup.sh

echo "Storing the host key fingerprint to avoid a question when using SSH for the first time."

result=`grep "ssh-dss" $HOME/.ssh/known_hosts | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t dsa localhost >> $HOME/.ssh/known_hosts
  ssh-keyscan -t dsa `hostname -f` >> $HOME/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t dsa `hostname` >> $HOME/.ssh/known_hosts
  fi
fi
result=`grep "ssh-rsa" $HOME/.ssh/known_hosts | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t rsa localhost >> $HOME/.ssh/known_hosts
  ssh-keyscan -t rsa `hostname -f` >> $HOME/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t rsa `hostname` >> $HOME/.ssh/known_hosts
  fi
fi

##########
# Update the sysctl file to set swappiness. And set it for the current session.
echo "SYSCTL.CONF: Setting swappiness to 10"
echo "SYSCTL.CONF: Disabling IPV6"
sudo cp $CDIR/sysctl.conf /etc/sysctl.conf
sudo sysctl vm.swappiness=10

##########
# Create a supergroup group and put the accumulo user in it so that
# the Accumulo monitor page can access the Namenode information.
result=`getent group supergroup | grep supergroup | wc -l`
if [ "$result" == "0" ];
then
  echo "Adding supergroup. Adding $USER to supergroup"
  sudo addgroup supergroup
  sudo adduser $USER supergroup
fi

# setup a source for maven3 which is required by Accumulo.
echo "deb http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update

sudo apt-get -y install curl maven2 openssh-server openssh-client terminator
sudo apt-get -y install openjdk-6-jdk subversion screen g++ make meld
sudo apt-get -y --force-yes install maven3

# remove the symbolic link to maven2. You can still access it via /usr/share/maven2/bin/mvn
sudo rm /usr/bin/mvn
sudo ln -s /usr/share/maven3/bin/mvn /usr/bin/mvn

#apt-get -y fail2bin
echo "Installed packages"

mkdir -p $HOME/software
mkdir -p $HOME/data
mkdir -p $HOME/bin

# install and configure hadoop
if [ ! -f $HOME/software/$HADOOP_VERSION/conf/core-site.xml ];
then
  cd $HOME/software
  tar xfz $CDIR/$HADOOP_VERSION.tar.gz
  rm -f $HOME/software/hadoop
  ln -s $HADOOP_VERSION hadoop
  cp $CDIR/core-site.xml $HOME/software/hadoop/conf/core-site.xml
  cp $CDIR/hdfs-site.xml $HOME/software/hadoop/conf/hdfs-site.xml
  cp $CDIR/mapred-site.xml $HOME/software/hadoop/conf/mapred-site.xml
  cp $CDIR/hadoop-env.sh $HOME/software/hadoop/conf/hadoop-env.sh
  cp $CDIR/generic_logger.xml $HOME/software/hadoop/conf
  cp $CDIR/monitor_logger.xml $HOME/software/hadoop/conf
  # Update master and slaves with the hostname
  hostname -f > $HOME/software/hadoop/conf/masters
  hostname -f > $HOME/software/hadoop/conf/slaves
  sed -i "s/localhost/`hostname -f`/" $HOME/software/hadoop/conf/core-site.xml
  sed -i "s/\/hadoop_tmp_dir/\/home\/$USER\/data\/hadoop_tmp_dir/" $HOME/software/hadoop/conf/core-site.xml
  sed -i "s/localhost/`hostname -f`/" $HOME/software/hadoop/conf/mapred-site.xml
fi

# Create the hadoop temp directory. It should not be in the /tmp directory because that directory
# disappears after each system restart. Something that is done a lot with virtual machines.
mkdir -p /home/$USER/data/hadoop_tmp_dir
chmod 755 /home/$USER/data//hadoop_tmp_dir
##########
# format hadoop, if needed
if [ ! -d /home/$USER/data/hadoop_tmp_dir/dfs/name ];
then
  $HOME/software/hadoop/bin/hadoop namenode -format
fi

##########
# If hadoop is not running, then format the namenode and start hadoop.
result=`ps faux | grep "proc_namenode" | wc -l`
if [ "$result" != "2" ];
then
  $HOME/software/hadoop/bin/start-dfs.sh
  # this creates /home/$USER directory in HDFS.
  $HOME/software/hadoop/bin/start-mapred.sh
fi

echo "Installed Hadoop"
echo "View http://localhost:50070 for Name Node monitor."
echo "View http://localhost:50030 for Job Tracker monitor."

# install and configure zookeeper
if [ ! -f $HOME/software/zookeeper-3.4.3/conf/zoo.cfg ];
then
  cd $HOME/software
  tar xfz $CDIR/zookeeper-3.4.3.tar.gz
  cp $CDIR/zoo.cfg $HOME/software/zookeeper-3.4.3/conf/zoo.cfg
  ln -s $HOME/software/zookeeper-3.4.3 $HOME/software/zookeeper
  mkdir -p $HOME/data/zookeeper_tmp_dir
  chmod 777 $HOME/data/zookeeper_tmp_dir
  sed -i "s/\/zookeeper_tmp_dir/\/home\/$USER\/data\/zookeeper_tmp_dir/" $HOME/software/zookeeper/conf/zoo.cfg
fi

# start zookeeper
result=`ps faux | grep "QuorumPeerMain" | wc -l`
if [ "$result" != "2" ];
then
  pushd $HOME/software/zookeeper; ./bin/zkServer.sh start; popd
fi

echo "Installed Zookeeper"

##########
# Create an hadoop user directory if needed. This is the HDFS default
# directory for the user.
result=`$HOME/software/hadoop/bin/hadoop fs -ls /user 2>/dev/null | grep $USER | wc -l`
if [ "$result" == "0" ];
then
  $HOME/software/hadoop/bin/hadoop fs -mkdir /user/$USER
fi

##########
# Create an accumulo hdfs directory if needed. This is the 
# HDFS directory for accumulo.
result=`$HOME/software/hadoop/bin/hadoop fs -ls /user 2>/dev/null | grep accumulo | wc -l`
if [ "$result" == "0" ];
then
  $HOME/software/hadoop/bin/hadoop fs -mkdir /user/accumulo
fi

echo "Connecting to apache.org. Please be patient..."

svn co https://svn.apache.org/repos/asf/accumulo/trunk $HOME/software/accumulo
echo "Cloned accumulo"

pushd $HOME/software/accumulo; mvn -DskipTests package -P assemble; popd
echo "Compiled accumulo"

# Make the lib/ext directory group writeable so that you can deply jar files there.
tar xfz $HOME/software/accumulo/assemble/target/$ACCUMULO_VERSION-bin.tar.gz -C $HOME/bin

# Compile the native libraries
#pushd $HOME/bin/$ACCUMULO_VERSION/server/src/main/c++; make; popd
#echo "Compiled navtive library"

# remove symbolic link and then create it.
rm -f $HOME/bin/accumulo
ln -s $HOME/bin/$ACCUMULO_VERSION $HOME/bin/accumulo

mkdir -p $HOME/bin/accumulo/lib/ext
mkdir -p $HOME/bin/accumulo/logs
mkdir -p $HOME/bin/accumulo/walogs

echo "Created ext, logs, and walogs directory."

cp $HOME/bin/accumulo/conf/examples/512MB/standalone/* $HOME/bin/accumulo/conf
cp $CDIR/accumulo-site.xml $HOME/bin/accumulo/conf/accumulo-site.xml
cp $CDIR/accumulo-env_for_home_directory.sh $HOME/bin/accumulo/conf/accumulo-env.sh
hostname -f > $HOME/bin/accumulo/conf/gc
hostname -f > $HOME/bin/accumulo/conf/masters
hostname -f > $HOME/bin/accumulo/conf/monitor
hostname -f > $HOME/bin/accumulo/conf/slaves
hostname -f > $HOME/bin/accumulo/conf/tracers

echo "initializing accumulo"
$HOME/software/hadoop/bin/hadoop fs -rmr /user/accumulo/accumulo 2>/dev/null
$HOME/bin/accumulo/bin/accumulo init --clear-instance-name --instance-name instance --username root --password secret

exit

echo "starting accumulo"
$HOME/bin/accumulo/bin/start-all.sh

echo "------------------------"
echo "Please define the following variables:"
echo "  ACCUMULO_HOME=$HOME/bin/accumulo"
echo "  JAVA_HOME=/usr/lib/jvm/java-6-openjdk"
echo "  HADOOP_HOME=$HOME/software/hadoop"
echo "  ZOOKEEPER_HOME=$HOME/software/zookeeper"
echo "------------------------"

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
