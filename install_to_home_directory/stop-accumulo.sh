#!/bin/bash

echo "Stopping Accumulo"
kill -9 `jps -v | grep "accumulo.core" | cut -f1 -d' '` 2>/dev/null
