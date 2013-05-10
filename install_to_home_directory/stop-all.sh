#!/bin/bash

source setup.sh

echo "Stopping Accumulo"
kill -9 `jps -v | grep "accumulo.core" | cut -f1 -d' '` 2>/dev/null

echo "Stopping Hadoop"
kill -9 `jps | grep JobTracker | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep TaskTracker | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep SecondaryNameNode | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep DataNode | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep NameNode | cut -f1 -d' '` 2>/dev/null

echo "Stopping Zookeeper"
kill -9 `jps | grep QuorumPeerMain | cut -f1 -d' '` 2>/dev/null

rm -rf $BASE_DIR $HOME/.accumulo

