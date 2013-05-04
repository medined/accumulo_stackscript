#!/bin/bash

echo "You are about to update Accumulo in your HOME directory."
echo "Press <ENTER> to continue> "
read

$HOME/bin/accumulo/bin/stop-all.sh

export CDIR=`pwd`
export LOGFILE=$HOME/build.log
export PASSWORD=`openssl passwd -1 password`

##########
# enable logging. Logs both to file and screen. 
exec 2>&1
exec > >(tee -a $LOGFILE)

echo "- START ------------"
date +"%Y/%m/%d %H:%M:%S"

cd $HOME/software/accumulo
svn update
echo "Update accumulo svn directory."

pushd $HOME/software/accumulo; mvn -DskipTests package -P assemble; popd
echo "Compiled accumulo"

# Make the lib/ext directory group writeable so that you can deply jar files there.
tar xfz $HOME/software/accumulo/assemble/target/apache-accumulo-1.6.0-SNAPSHOT-dist.tar.gz -C $HOME/bin

# Compile the native libraries
pushd $HOME/bin/apache-accumulo-1.6.0-SNAPSHOT/server/src/main/c++; make; popd
echo "Compiled navtive library"

# remove symbolic link and then create it.
rm -f $HOME/bin/accumulo
ln -s $HOME/bin/apache-accumulo-1.6.0-SNAPSHOT $HOME/bin/accumulo

mkdir -p $HOME/bin/accumulo/lib/ext
mkdir -p $HOME/bin/accumulo/logs
mkdir -p $HOME/bin/accumulo/walogs

echo "Created ext, logs, and walogs directory."

cp $HOME/bin/accumulo/conf/examples/512MB/standalone/* $HOME/bin/accumulo/conf
cp $CDIR/accumulo-site.xml $HOME/bin/accumulo/conf/accumulo-site.xml
cp $CDIR/accumulo-env.sh $HOME/bin/accumulo/conf/accumulo-env.sh
hostname -f > $HOME/bin/accumulo/conf/gc
hostname -f > $HOME/bin/accumulo/conf/masters
hostname -f > $HOME/bin/accumulo/conf/monitor
hostname -f > $HOME/bin/accumulo/conf/slaves
hostname -f > $HOME/bin/accumulo/conf/tracers

########

echo "starting accumulo"
$HOME/bin/accumulo/bin/start-all.sh

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
