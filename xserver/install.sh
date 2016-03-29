#!/bin/bash

cat > /etc/init/openbox.conf <<- EOM
start on runlevel [2345]
stop on runlevel [016]

setuid codio
setgid codio

respawn
respawn limit 10 5

script
exec /usr/bin/xvfb-run --auth-file=/tmp/codio.auth --server-args="-screen 0 1328x768x24 -ac -extension GLX" --server-num=0 openbox
end script
EOM

cat > /etc/init/x11vnc.conf <<- EOM
start on started openbox
stop on runlevel [016]

env DAEMON='x11vnc -auth /tmp/codio.auth -display :0 -listen localhost -noncache -shared -forever'
setuid codio
setgid codio
respawn
respawn limit 10 5
exec \$DAEMON
EOM

cat > /etc/init/novnc.conf <<- EOM
start on started x11vnc
stop on runlevel [016]
env DAEMON='websockify --heartbeat 20 --web /opt/novnc/noVNC-master 9500 localhost:5900'
respawn
pre-start script
  cp /opt/novnc/noVNC-master/vnc_auto.html /opt/novnc/noVNC-master/index.html
end script
respawn limit 10 5
exec \$DAEMON
EOM

cat > /etc/init/novnc-3000.conf <<- EOM
start on started x11vnc
stop on runlevel [016]
env DAEMON='websockify --heartbeat 20 --web /opt/novnc/noVNC-master 3000 localhost:5900'
respawn
pre-start script
  cp /opt/novnc/noVNC-master/vnc_auto.html /opt/novnc/noVNC-master/index.html
end script
respawn limit 10 5
exec \$DAEMON
EOM

cat >> ~/.bash_profile <<- EOM
    export DISPLAY=:0
    export XAUTHORITY=/tmp/codio.auth
EOM

apt-get -y update || true
apt-get install -y xvfb x11vnc openbox python-dev python-pip unzip || true
wget https://github.com/kanaka/noVNC/archive/master.zip -O /tmp/novnc.zip
unzip /tmp/novnc.zip -d /opt/novnc
rm /tmp/novnc.zip

pip install websockify

echo "please restart the box"
