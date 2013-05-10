#!/bin/bash

CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
if [ ${CAN_I_RUN_SUDO} -eq 0 ]
then
    echo "I am sorry but you can't run this script without the ability to use"
    echo "SUDO because the script uses apt-get to install software packages."
    echo ""
    echo "All use of sudo is done inside sudo-tasks.sh and install-packages.sh"
    echo "If your system administrator runs those two scripts then you can "
    echo "this driver script to exclude them."
    exit
fi

echo "You are about to install software into your HOME directory."
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

source ./sudo-tasks.sh
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
echo ""
echo "Don't forget to update your PATH! Check setup.sh"
echo "if you need hints."
echo "------------------------"

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
echo
