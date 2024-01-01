#!/bin/bash

sudo su
cat <<EOF > /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF
cat <<EOF > /var/log/watchlog.log
ALERT
ALERT
ALERT
EOF
cat <<EOF > /opt/watchlog.sh
#!/bin/bash
WORD=\$1
LOG=\$2
DATE=\$(date)

if grep "\$WORD" "\$LOG" &> /dev/null; then
  logger "\$DATE: I found word, Master!"
else
  exit 0
fi
EOF
chmod +x /opt/watchlog.sh
cat <<EOF > /etc/systemd/system/watchmyword.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
EOF

chmod 664 /etc/systemd/system/watchmyword.service

cat <<EOF > /etc/systemd/system/watchmyword.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchmyword.service

[Install]
WantedBy=multi-user.target
EOF
chmod 664 /etc/systemd/system/watchmyword.timer

systemctl start watchmyword.timer




sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum install epel-release -y
yum install spawn-fcgi php php-cli mod_fcgid httpd -y
sed -i 's/#SOCKET=\/var\/run\/php-fcgi.sock/SOCKET=\/var\/run\/php-fcgi.sock/g' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P \/var\/run\/spawn-fcgi.pid -- \/usr\/bin\/php-cgi"/OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P \/var\/run\/spawn-fcgi.pid -- \/usr\/bin\/php-cgi"/g' /etc/sysconfig/spawn-fcgi
cat <<EOF > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
systemctl start spawn-fcgi



