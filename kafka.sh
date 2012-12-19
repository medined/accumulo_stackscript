
# This should be sourced by a calling script but reloading it
# does not hurt.
source setup.sh

if [ ! -f /usr/local/$KAFKA_VERSION/CHANGES.txt ];
then
  echo ""
  echo "==========================================="
  echo "KAFKA: Install and configure"
  add_a_user kafka
  tar xfz $CDIR/$KAFKA_VERSION.tar.gz -C /usr/local
  chown -R kafka:kafka /usr/local/$KAFKA_VERSION
  rm -f /usr/local/kafka
  ln -s $KAFKA_VERSION kafka
  cd /usr/local/kafka
  # my version of the property file uses a rolling file appender.
  su kafka -c "cp $CDIR/kafka_log4j.properties /usr/local/kafka/config"
  su kafka -c "./sbt update"
  su kafka -c "./sbt package"
  su kafka -c "/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &"
fi

echo "Installed Kafka"
