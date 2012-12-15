Accumulo Stackscript
====================

Provides stackscripts to install hadoop, zookeeper and accumulo on a Linode server. 

I wanted a way to test the very latest Accumulo code. I could not use any of my existing systems because they were multi-use boxes. So I wrote a Stackscript in order to prepare a Linode server. Note that this script pulls a few files from my affy.com server for simplicity.

Users: hadoop, zookeeper, accumulo
Password: password

This stackscript downloads, installs and configures hadoop, zookeeper, and accumulo.

Step one is to create your own stackscript. Mine was called "InitializeAccumulo". The idea is that the starter script pulls the actual script from some server so that you don't need to deal with the 'Manage Stackscript' interface. The starter script is:

```bash
#!/bin/bash
wget https://raw.github.com/medined/accumulo_stackscript/master/linode_build_v00/stackscript -O /tmp/stackscript.sh
chmod +x /tmp/stackscript.sh
/tmp/stackscript.sh
```

After the Linode server boots, it will take about 10 minutes to run this script. Then you can use ssh to login as the 'accumulo' user (the password is 'password'). Run two more commands and your server is completely setup.

```bash
accumulo init --clear-instance-name --instance-name instance --password secret
cd /usr/local/accumulo
bin/start-all.sh
```

Screen
======

http://library.linode.com/linux-tools/utilities/screen - the Stackscript installs screen which is useful so that you can always connect to the same session. Type Ctl-A+d in order to detach the session. Use screen -r to reconnect.

