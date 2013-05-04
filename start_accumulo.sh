#
# startup hadoop
if [ -d $HOME/software/hadoop ];
then
  $HOME/software/hadoop/bin/start-dfs.sh
  $HOME/software/hadoop/bin/start-mapred.sh
else
  su hadoop -c "/usr/local/hadoop/bin/start-dfs.sh"
  su hadoop -c "/usr/local/hadoop/bin/start-mapred.sh"
fi

#
# startup zookeeer
#
if [ -d $HOME/software/zookeeper ];
then
  pushd $HOME/software/zookeeper; ./bin/zkServer.sh start; popd
else
  su zookeeper -c "pushd /usr/local/zookeeper; ./bin/zkServer.sh start; popd"
fi

#
# On my system, hadoop starts in safe mode and I need to
# force it to leave. Have no idea why since I am closing
# the processes cleanly.
#
sleep 2
if [ -d $HOME/software/hadoop ];
then
  $HOME/software/hadoop/bin/hadoop dfsadmin -safemode leave
else
  su hadoop -c "/usr/local/hadoop/bin/hadoop dfsadmin -safemode leave"
fi

#
# startup accumulo
#
if [ -d $HOME/bin/accumulo ];
then
   $HOME/bin/accumulo/bin/start-all.sh
else
  su accumulo -c "/usr/local/accumulo/bin/start-all.sh"
fi

