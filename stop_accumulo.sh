#
# shutdown accumulo
#
if [ -d $HOME/bin/accumulo ];
then
   $HOME/bin/accumulo/bin/stop-all.sh
else
  su accumulo -c "/usr/local/accumulo/bin/stop-all.sh"
fi

#
# shutdown zookeeer
#
if [ -d $HOME/software/zookeeper ];
then
  pushd $HOME/software/zookeeper; ./bin/zkServer.sh stop; popd
else
  su zookeeper -c "pushd /usr/local/zookeeper; ./bin/zkServer.sh stop; popd"
fi

#
# shutdown hadoop
if [ -d $HOME/software/hadoop ];
then
  $HOME/software/hadoop/bin/stop-mapred.sh
  $HOME/software/hadoop/bin/stop-dfs.sh
else
  su hadoop -c "/usr/local/hadoop/bin/stop-mapred.sh"
  su hadoop -c "/usr/local/hadoop/bin/stop-dfs.sh"
fi
