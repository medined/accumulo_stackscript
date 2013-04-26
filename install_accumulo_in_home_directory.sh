#!/bin/bash

echo "You are about to install software into your HOME directory. You must have SUDO"
echo "privileges! If you don't exit this script (^c) and get them."
echo "Press <ENTER> to continue> "
read

#~/bin/accumulo/bin/stop-all.sh
~/software/hadoop/bin/stop-mapred.sh
~/software/hadoop/bin/stop-dfs.sh
~/software/zookeeper/bin/zkServer.sh stop
rm -rf ~/bin ~/data ~/software

export HADOOP_VERSION=hadoop-1.0.4
export CDIR=`pwd`
export LOGFILE=~/build.log
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
sudo cp $CDIR/login_startup.sh /etc/profile.d
source /etc/profile.d/login_startup.sh

echo "Storing the host key fingerprint to avoid a question when using SSH for the first time."

result=`grep "ssh-dss" ~/.ssh/known_hosts | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t dsa localhost >> ~/.ssh/known_hosts
  ssh-keyscan -t dsa `hostname -f` >> ~/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t dsa `hostname` >> ~/.ssh/known_hosts
  fi
fi
result=`grep "ssh-rsa" ~/.ssh/known_hosts | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t rsa localhost >> ~/.ssh/known_hosts
  ssh-keyscan -t rsa `hostname -f` >> ~/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t rsa `hostname` >> ~/.ssh/known_hosts
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

##########
# Setup the firewall (allow the hadoop, job tracker, and accumulo web pages)
#sudo cp $CDIR/iptables.firewall.rules /etc/iptables.firewall.rules
#sudo cp $CDIR/firewall /etc/network/if-pre-up.d/firewall
#sudo iptables-restore < /etc/iptables.firewall.rules

# setup a source for maven3 which is required by Accumulo.
echo "deb http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update

sudo apt-get -y install curl maven2 openssh-server openssh-client terminator
sudo apt-get -y install openjdk-6-jdk subversion screen g++ make
sudo apt-get -y --force-yes install maven3

# remove the symbolic link to maven2. You can still access it via /usr/share/maven2/bin/mvn
sudo rm /usr/bin/mvn
sudo ln -s /usr/share/maven3/bin/mvn /usr/bin/mvn

#apt-get -y fail2bin
echo "Installed packages"

mkdir -p ~/software
mkdir -p ~/data
mkdir -p ~/bin

# install and configure hadoop
if [ ! -f ~/software/$HADOOP_VERSION/conf/core-site.xml ];
then
  cd ~/software
  tar xfz $CDIR/$HADOOP_VERSION.tar.gz
  rm -f ~/software/hadoop
  ln -s $HADOOP_VERSION hadoop
  cp $CDIR/core-site.xml ~/software/hadoop/conf/core-site.xml
  cp $CDIR/hdfs-site.xml ~/software/hadoop/conf/hdfs-site.xml
  cp $CDIR/mapred-site.xml ~/software/hadoop/conf/mapred-site.xml
  cp $CDIR/hadoop-env.sh ~/software/hadoop/conf/hadoop-env.sh
  cp $CDIR/generic_logger.xml ~/software/hadoop/conf
  cp $CDIR/monitor_logger.xml ~/software/hadoop/conf
  # Update master and slaves with the hostname
  hostname -f > ~/software/hadoop/conf/masters
  hostname -f > ~/software/hadoop/conf/slaves
  sed -i "s/localhost/`hostname -f`/" ~/software/hadoop/conf/core-site.xml
  sed -i "s/\/hadoop_tmp_dir/\/home\/$USER\/data\/hadoop_tmp_dir/" ~/software/hadoop/conf/core-site.xml
  sed -i "s/localhost/`hostname -f`/" ~/software/hadoop/conf/mapred-site.xml
fi

# Create the hadoop temp directory. It should not be in the /tmp directory because that directory
# disappears after each system restart. Something that is done a lot with virtual machines.
mkdir -p /home/$USER/data/hadoop_tmp_dir
chmod 755 /home/$USER/data//hadoop_tmp_dir
##########
# format hadoop, if needed
if [ ! -d /home/$USER/data/hadoop_tmp_dir/dfs/name ];
then
  ~/software/hadoop/bin/hadoop namenode -format
fi

##########
# If hadoop is not running, then format the namenode and start hadoop.
result=`ps faux | grep "proc_namenode" | wc -l`
if [ "$result" != "2" ];
then
  ~/software/hadoop/bin/start-dfs.sh
  # this creates /home/$USER directory in HDFS.
  ~/software/hadoop/bin/start-mapred.sh
fi

echo "Installed Hadoop"
echo "View http://localhost:50070 for Name Node monitor."
echo "View http://localhost:50030 for Job Tracker monitor."

# install and configure zookeeper
if [ ! -f ~/software/zookeeper-3.4.3/conf/zoo.cfg ];
then
  cd ~/software
  tar xfz $CDIR/zookeeper-3.4.3.tar.gz
  cp $CDIR/zoo.cfg ~/software/zookeeper-3.4.3/conf/zoo.cfg
  ln -s ~/software/zookeeper-3.4.3 ~/software/zookeeper
  mkdir -p ~/data/zookeeper_tmp_dir
  chmod 777 ~/data/zookeeper_tmp_dir
  sed -i "s/\/zookeeper_tmp_dir/\/home\/$USER\/data\/zookeeper_tmp_dir/" ~/software/zookeeper/conf/zoo.cfg
fi

# start zookeeper
result=`ps faux | grep "QuorumPeerMain" | wc -l`
if [ "$result" != "2" ];
then
  pushd ~/software/zookeeper; ./bin/zkServer.sh start; popd
fi

echo "Installed Zookeeper"

##########
# Create an hadoop user directory if needed. This is the HDFS default
# directory for the user.
result=`~/software/hadoop/bin/hadoop fs -ls /user | grep $USER | wc -l`
if [ "$result" == "0" ];
then
  ~/software/hadoop/bin/hadoop fs -mkdir /user/$USER
fi

##########
# Create an accumulo hdfs directory if needed. This is the 
# HDFS directory for accumulo.
result=`~/software/hadoop/bin/hadoop fs -ls /user | grep accumulo | wc -l`
if [ "$result" == "0" ];
then
  ~/software/hadoop/bin/hadoop fs -mkdir /user/accumulo
fi

svn co https://svn.apache.org/repos/asf/accumulo/trunk ~/software/accumulo
echo "Cloned accumulo"

pushd ~/software/accumulo; mvn -DskipTests package -P assemble; popd
echo "Compiled accumulo"

# Make the lib/ext directory group writeable so that you can deply jar files there.
tar xfz ~/software/accumulo/assemble/target/apache-accumulo-1.6.0-SNAPSHOT-dist.tar.gz -C ~/bin

# Compile the native libraries
pushd ~/bin/apache-accumulo-1.6.0-SNAPSHOT/server/src/main/c++; make; popd
echo "Compiled navtive library"

# remove symbolic link and then create it.
rm -f ~/bin/accumulo
ln -s ~/bin/apache-accumulo-1.6.0-SNAPSHOT ~/bin/accumulo

mkdir -p ~/bin/accumulo/lib/ext
mkdir -p ~/bin/accumulo/logs
mkdir -p ~/bin/accumulo/walogs

echo "Created ext, logs, and walogs directory."

cp ~/bin/accumulo/conf/examples/512MB/standalone/* ~/bin/accumulo/conf
cp $CDIR/accumulo-site.xml ~/bin/accumulo/conf/accumulo-site.xml
cp $CDIR/accumulo-env.sh ~/bin/accumulo/conf/accumulo-env.sh
hostname -f > ~/bin/accumulo/conf/gc
hostname -f > ~/bin/accumulo/conf/masters
hostname -f > ~/bin/accumulo/conf/monitor
hostname -f > ~/bin/accumulo/conf/slaves
hostname -f > ~/bin/accumulo/conf/tracers

########

#echo "initializing accumulo"
~/software/hadoop/bin/hadoop fs -rmr /user/accumulo/accumulo 2>/dev/null
~/bin/accumulo/bin/accumulo init --clear-instance-name --instance-name instance --username root --password secret

echo "starting accumulo"
~/bin/accumulo/bin/start-all.sh

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
