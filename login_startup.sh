export DEFAULT_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# setup java home
if [ -d /usr/lib/jvm/java-6-openjdk ];
then
  # Ubuntu 10.04 (and perhaps others)
  export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
fi
if [ -d /usr/lib/jvm/java-6-openjdk-i386 ];
then
  export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-i386
fi
if [ "$JAVA_HOME" == "" ];
then
  echo "UNABLE TO SET JAVA_HOME!"
fi

# setup hadoop home and prefix
if [ -d /usr/local/hadoop ];
then
  export HADOOP_HOME=/usr/local/hadoop
  export HADOOP_PREFIX=/usr/local/hadoop
fi
# an installation of hadoop in home directory overides

if [ -d $HOME/software/hadoop-1.0.4 ];
then
  export HADOOP_HOME=$HOME/software/hadoop-1.0.4
  export HADOOP_PREFIX=$HOME/software/hadoop-1.0.4
fi
if [ "$HADOOP_HOME" == "" ];
then
  echo "UNABLE TO SET HADOOP_HOME!"
fi

# setup zookeeper home
if [ -d /usr/local/zookeeper ];
then
  export ZOOKEEPER_HOME=/usr/local/zookeeper
fi
# an installation of zookeeper in home directory overides
if [ -d $HOME/software/zookeeper-3.4.3 ];
then
  export ZOOKEEPER_HOME=$HOME/software/zookeeper-3.4.3
fi
if [ "$ZOOKEEPER_HOME" == "" ];
then
  echo "UNABLE TO SET ZOOKEEPER_HOME!"
fi

# setup accumulo home
if [ -d /usr/local/accumulo ];
then
  export ACCUMULO_HOME=/usr/local/accumulo
fi
# an installation of accumulo in home directory overides
if [ -d $HOME/bin/apache-accumulo-1.6.0-SNAPSHOT ];
then
  export ACCUMULO_HOME=$HOME/bin/apache-accumulo-1.6.0-SNAPSHOT
fi
if [ "$ACCUMULO_HOME" == "" ];
then
  echo "UNABLE TO SET ACCUMULO_HOME!"
fi

export KAFKA_HOME=/usr/local/kafka
export PATH=$ACCUMULO_HOME/bin:$HADOOP_PREFIX/bin:$JAVA_HOME/bin:$KAFKA_HOME/bin:$ZOOKEEPER_HOME/bin:$DEFAULT_PATH

alias la="ls -lah"

