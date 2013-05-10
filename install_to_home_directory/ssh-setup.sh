#!/bin/bash

#
# Notice this file uses HOME instead of HOME
#

source ./setup.sh

echo "Storing the host key fingerprint to avoid a question when using SSH for the first time."

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh

if [ ! -f $HOME/.ssh/id_rsa ];
then
  ssh-keygen -t rsa -P '' -f $HOME/.ssh/id_rsa
  cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
fi
if [ ! -f $HOME/.ssh/id_dsa ];
then
  ssh-keygen -t dsa -P '' -f $HOME/.ssh/id_dsa
  cat $HOME/.ssh/id_dsa.pub >> $HOME/.ssh/authorized_keys
fi
chmod 600 $HOME/.ssh/authorized_keys

result=`grep "ssh-dss" $HOME/.ssh/known_hosts 2>/dev/null | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t dsa localhost >> $HOME/.ssh/known_hosts
  ssh-keyscan -t dsa `hostname -f` >> $HOME/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t dsa `hostname` >> $HOME/.ssh/known_hosts
  fi
fi

result=`grep "ssh-rsa" $HOME/.ssh/known_hosts 2>/dev/null | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t rsa localhost >> $HOME/.ssh/known_hosts
  ssh-keyscan -t rsa `hostname -f` >> $HOME/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t rsa `hostname` >> $HOME/.ssh/known_hosts
  fi
fi

