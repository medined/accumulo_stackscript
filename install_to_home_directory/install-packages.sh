#!/bin/bash

source setup.sh

# setup a source for maven3 which is required by Accumulo.
echo "deb http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/natecarlson/maven3/ubuntu precise main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update

sudo apt-get -y install curl maven2 openssh-server openssh-client terminator
sudo apt-get -y install openjdk-6-jdk subversion screen g++ make meld build-essential g++-multilib
sudo apt-get -y --force-yes install maven3

# remove the symbolic link to maven2. You can still access it via /usr/share/maven2/bin/mvn
sudo rm /usr/bin/mvn
sudo ln -s /usr/share/maven3/bin/mvn /usr/bin/mvn

echo "Installed packages"

