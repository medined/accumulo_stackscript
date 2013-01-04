su accumulo -c "/usr/local/accumulo/bin/stop-all.sh"
su zookeeper -c "cd /usr/local/zookeeper; ./bin/zkServer.sh stop"
su hadoop -c "/usr/local/hadoop/bin/stop-mapred.sh"
su hadoop -c "/usr/local/hadoop/bin/stop-dfs.sh"
