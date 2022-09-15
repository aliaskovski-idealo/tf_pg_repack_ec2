#!/bin/bash

# logs in /var/log/cloud-init.log and /var/log/cloud-init-output.log

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

apt-get update -y
apt-get install -y jq ec2-instance-connect telnet postgresql make unzip gcc libssl-dev zlib1g-dev libreadline-dev libpq-dev postgresql-common postgresql-14-repack
#wget -q -O pg_repack.zip "https://api.pgxn.org/dist/pg_repack/1.4.7/pg_repack-1.4.7.zip"
#unzip pg_repack.zip && rm -f pg_repack.zip
#cd pg_repack-*
#make && make install
#cd ..
#rm -rf pg_repack-*
apt-get remove --auto-remove -y make unzip gcc libssl-dev zlib1g-dev libreadline-dev
