#!/bin/bash

# logs in /var/log/cloud-init.log and /var/log/cloud-init-output.log

yum update -y

yum install -y jq ec2-instance-connect nc telnet make unzip gcc libssl-dev zlib1g-dev libreadline-dev
amazon-linux-extras install postgresql14 -y

wget -q -O pg_repack.zip "https://api.pgxn.org/dist/pg_repack/1.4.6/pg_repack-1.4.6.zip"
unzip pg_repack.zip && rm pg_repack.zip
cd pg_repack-*
make && make install
cd ..
rm -rf pg_repack-*

# install and configure fail2ban
amazon-linux-extras install epel -y
yum -y install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/^\[sshd\]/[sshd]\nenabled=true/" /etc/fail2ban/jail.local
sed -i "s/maxretry = 5/maxretry = 100/" /etc/fail2ban/jail.local
systemctl restart fail2ban

# add daily cron for regular updates
(crontab -l 2>/dev/null; echo "0 2 * * * /bin/yum -y update && yum clean all") | crontab -

# cloudwatch logging
yum install -y awslogs
sed -i "s/us-east-1/${region}/" /etc/awslogs/awscli.conf
sed -i "s/log_group_name = \/var\/log\/messages/log_group_name = \/aws\/ec2\/pg_repack\/" /etc/awslogs/awslogs.conf
sudo cat << EOF >> /etc/awslogs/awslogs.conf
[/var/log/dmesg]
file = /var/log/dmesg
log_stream_name = /var/log/dmesg
log_group_name = /aws/ec2/pg_repack

[/var/log/secure]
file = /var/log/secure
log_stream_name = /var/log/secure
log_group_name = /aws/ec2/pg_repack

[/var/log/audit/audit.log]
file = /var/log/audit/audit.log
log_stream_name = /var/log/audit
log_group_name = /aws/ec2/pg_repack

[/var/log/cron]
file = /var/log/cron
log_stream_name = /var/log/cron
log_group_name = /aws/ec2/pg_repack

EOF

service awslogs start
systemctl start awslogsd
chkconfig awslogs on
systemctl enable awslogsd.service


yum clean all