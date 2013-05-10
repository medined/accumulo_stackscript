#!/bin/bash

echo "Stopping Hadoop"
kill -9 `jps | grep JobTracker | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep TaskTracker | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep SecondaryNameNode | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep DataNode | cut -f1 -d' '` 2>/dev/null
kill -9 `jps | grep NameNode | cut -f1 -d' '` 2>/dev/null
