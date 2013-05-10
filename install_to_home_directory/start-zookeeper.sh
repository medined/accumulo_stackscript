#!/bin/bash

source ./setup.sh
source ./stop-zookeeper.sh

pushd $BASE_DIR/bin/zookeeper; ./bin/zkServer.sh start; popd
