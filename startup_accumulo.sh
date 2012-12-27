su hadoop -c "/usr/local/hadoop/bin/start-dfs.sh"
su hadoop -c "/usr/local/hadoop/bin/start-mapred.sh"
su zookeeper -c "cd /usr/local/zookeeper; ./bin/zkServer.sh start"
su accumulo -c "/usr/local/accumulo-1.5.0-SNAPSHOT/bin/start-all.sh"
