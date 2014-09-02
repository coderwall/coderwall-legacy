#!/bin/bash -x
export DEBIAN_FRONTEND=noninteractive
cd /home/vagrant
echo Who am I? You are `whoami`.
echo Where am I? You are in `pwd`
echo I think my home is $HOME
echo export EDITOR=vim >> $HOME/.bashrc
# Enable accessing Postgres from the host machine
apt-get -y install libcurl3 libcurl3-dev libcurl3-gnutls libcurl4-openssl-dev
apt-get -y install libpq-dev
apt-get -y install libxml2 libxml2-dev libxslt1-dev
echo "listen_addresses = '*'" | tee -a /var/pgsql/data/postgresql.conf
echo host all all  0.0.0.0/0 trust | tee -a  /var/pgsql/data/pg_hba.conf
sudo su postgres -c 'pg_ctl stop -D /var/pgsql/data  2>&1'
sudo su postgres -c 'pg_ctl start -D /var/pgsql/data  2>&1 &'
su -c "ln -s /vagrant /home/vagrant/web" vagrant
su -c "source /home/vagrant/web/vagrant/user-config.sh" vagrant
