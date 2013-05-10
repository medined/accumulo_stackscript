#!/bin/bash

echo "Stopping Zookeeper"
kill -9 `jps | grep QuorumPeerMain | cut -f1 -d' '` 2>/dev/null
