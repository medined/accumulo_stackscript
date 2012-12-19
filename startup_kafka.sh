su zookeeper -c "cd /usr/local/zookeeper; ./bin/zkServer.sh start"
su kafka -c "/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &"
