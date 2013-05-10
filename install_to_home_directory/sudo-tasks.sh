#!/bin/bash

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

