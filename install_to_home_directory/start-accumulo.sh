#!/bin/bash

source ./setup.sh
source ./stop-accumulo.sh

$BASE_DIR/bin/accumulo/bin/start-all.sh

echo "View http://localhost:50095 for Accumulo monitor."
