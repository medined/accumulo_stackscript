#!/bin/bash

echo "You are about to update Accumulo in your HOME directory."
echo "Press <ENTER> to continue> "
read

~/bin/accumulo/bin/stop-all.sh

export CDIR=`pwd`
export LOGFILE=~/build.log
export PASSWORD=`openssl passwd -1 password`

##########
# enable logging. Logs both to file and screen. 
exec 2>&1
exec > >(tee -a $LOGFILE)

echo "- START ------------"
date +"%Y/%m/%d %H:%M:%S"

cd ~/software/accumulo
svn update
echo "Update accumulo svn directory."

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

echo "starting accumulo"
~/bin/accumulo/bin/start-all.sh

date +"%Y/%m/%d %H:%M:%S"
echo "- END ------------"
