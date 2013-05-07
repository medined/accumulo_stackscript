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

source stop-all.sh
source ssh-setup.sh

export CDIR=`pwd`

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

source install-packages.sh
source install-hadoop.sh
source install-zookeeper.sh
source install-accumulo.sh

echo "------------------------"
echo "Please define the following variables:"
echo "  ACCUMULO_HOME=$HOME/bin/accumulo"
echo "  JAVA_HOME=/usr/lib/jvm/java-6-openjdk"
echo "  HADOOP_HOME=$HOME/software/hadoop"
echo "  ZOOKEEPER_HOME=$HOME/software/zookeeper"
echo "------------------------"

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
