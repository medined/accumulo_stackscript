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
echo "After Accumulo is installed, you'll be prompted to enter the "
echo "instance name and password so it can be initialized"
echo ""
echo "Press <ENTER> to continue> "
read

source ./stop-all.sh
source ./ssh-setup.sh

##########
# Before this script is called have your system do:
#
# apt-get -y install git
# git clone https://github.com/medined/accumulo_stackscript.git

echo "- START ------------"
date +"%Y/%m/%d %H:%M:%S"

##########
# Update the sysctl file to set swappiness. And set it for the current session.
echo "SYSCTL.CONF: Setting swappiness to 10"
echo "SYSCTL.CONF: Disabling IPV6"
sudo cp ../sysctl.conf /etc/sysctl.conf
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

source ./install-packages.sh
source ./install-hadoop.sh
source ./install-zookeeper.sh
source ./install-accumulo-1.4.2.sh

source ./start-all.sh

echo "------------------------"
echo "Please define the following variables:"
echo "  ACCUMULO_HOME=$BASE_DIR/bin/accumulo"
echo "  JAVA_HOME=/usr/lib/jvm/java-6-openjdk"
echo "  HADOOP_HOME=$BASE_DIR/bin/hadoop"
echo "  HADOOP_PREFIX=$BASE_DIR/bin/hadoop"
echo "  ZOOKEEPER_HOME=$BASE_DIR/bin/zookeeper"
echo "------------------------"

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
echo
