#
# shutdown accumulo
#
if [ -d ~/bin/accumulo ];
then
   ~/bin/accumulo/bin/stop-all.sh
else
  su accumulo -c "/usr/local/accumulo/bin/stop-all.sh"
fi

#
# shutdown zookeeer
#
if [ -d ~/software/zookeeper ];
then
  pushd ~/software/zookeeper; ./bin/zkServer.sh stop; popd
else
  su zookeeper -c "pushd /usr/local/zookeeper; ./bin/zkServer.sh stop; popd"
fi

#
# shutdown hadoop
if [ -d ~/software/hadoop ];
then
  ~/software/hadoop/bin/stop-mapred.sh
  ~/software/hadoop/bin/stop-dfs.sh
else
  su hadoop -c "/usr/local/hadoop/bin/stop-mapred.sh"
  su hadoop -c "/usr/local/hadoop/bin/stop-dfs.sh"
fi
