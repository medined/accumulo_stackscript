#!/bin/bash

source setup.sh

echo "Storing the host key fingerprint to avoid a question when using SSH for the first time."

mkdir -p $BASE_DIR/.ssh
chmod 700 $BASE_DIR/.ssh

if [ ! -f $BASE_DIR/.ssh/id_rsa ];
then
  ssh-keygen -t rsa -P '' -f $BASE_DIR/.ssh/id_rsa
  cat $BASE_DIR/.ssh/id_rsa.pub >> $BASE_DIR/.ssh/authorized_keys
fi
if [ ! -f $BASE_DIR/.ssh/id_dsa ];
then
  ssh-keygen -t dsa -P '' -f $BASE_DIR/.ssh/id_dsa
  cat $BASE_DIR/.ssh/id_dsa.pub >> $BASE_DIR/.ssh/authorized_keys
fi
chmod 600 $BASE_DIR/.ssh/authorized_keys

result=`grep "ssh-dss" $BASE_DIR/.ssh/known_hosts 2>/dev/null | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t dsa localhost >> $BASE_DIR/.ssh/known_hosts
  ssh-keyscan -t dsa `hostname -f` >> $BASE_DIR/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t dsa `hostname` >> $BASE_DIR/.ssh/known_hosts
  fi
fi

result=`grep "ssh-rsa" $BASE_DIR/.ssh/known_hosts 2>/dev/null | wc -l`
if [ "$result" == "0" ];
then
  ssh-keyscan -t rsa localhost >> $BASE_DIR/.ssh/known_hosts
  ssh-keyscan -t rsa `hostname -f` >> $BASE_DIR/.ssh/known_hosts
  if [ "`hostname -f`" != "`hostname`" ];
  then
    ssh-keyscan -t rsa `hostname` >> $BASE_DIR/.ssh/known_hosts
  fi
fi

