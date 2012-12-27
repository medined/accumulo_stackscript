bin/kafka-console-producer.sh --zookeeper localhost:2181 --topic test

bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning

export JAVA_OPTS="-Xmx3600M -Xms256M"

/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &

/usr/local/kafka/bin/kafka-server-stop.sh

