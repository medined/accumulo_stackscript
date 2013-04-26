#
# startup hadoop
if [ -d ~/software/hadoop ];
then
  ~/software/hadoop/bin/start-dfs.sh
  ~/software/hadoop/bin/start-mapred.sh
else
  su hadoop -c "/usr/local/hadoop/bin/start-dfs.sh"
  su hadoop -c "/usr/local/hadoop/bin/start-mapred.sh"
fi

#
# startup zookeeer
#
if [ -d ~/software/zookeeper ];
then
  pushd ~/software/zookeeper; ./bin/zkServer.sh start; popd
else
  su zookeeper -c "pushd /usr/local/zookeeper; ./bin/zkServer.sh start; popd"
fi

#
# startup accumulo
#
if [ -d ~/bin/accumulo ];
then
   ~/bin/accumulo/bin/start-all.sh
else
  su accumulo -c "/usr/local/accumulo/bin/start-all.sh"
fi

