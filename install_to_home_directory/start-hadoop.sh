#!/bin/bash

source ./setup.sh
source ./stop-hadoop.sh

$BASE_DIR/bin/hadoop/bin/start-dfs.sh
# this creates /home/$USER directory in HDFS.
$BASE_DIR/bin/hadoop/bin/start-mapred.sh

echo "View http://localhost:50070 for Name Node monitor."
echo "View http://localhost:50030 for Job Tracker monitor."
