#!/bin/bash -x
export DEBIAN_FRONTEND=noninteractive

apt-get -y install ack-grep
apt-get -y install autoconf
apt-get -y install automake
apt-get -y install bash
apt-get -y install bison
apt-get -y install build-essential
apt-get -y install bzip2
apt-get -y install ca-certificates
apt-get -y install curl
apt-get -y install g++
apt-get -y install gawk
apt-get -y install gcc
apt-get -y install git-core
apt-get -y install htop
apt-get -y install imagemagick
apt-get -y install iotop
apt-get -y install libc6-dev
apt-get -y install libcurl3
apt-get -y install libcurl3-dev
apt-get -y install libcurl3-gnutls
apt-get -y install libcurl4-openssl-dev
apt-get -y install libffi-dev
apt-get -y install libgdbm-dev
apt-get -y install libmagickcore-dev
apt-get -y install libmagickwand-dev
apt-get -y install libncurses5-dev
apt-get -y install libopenssl-ruby
apt-get -y install libpq-dev
apt-get -y install libreadline6
apt-get -y install libreadline6-dev
apt-get -y install libsqlite3-0
apt-get -y install libsqlite3-dev
apt-get -y install libssl-dev
apt-get -y install libtool
apt-get -y install libxml2
apt-get -y install libxml2-dev
apt-get -y install libxslt-dev
apt-get -y install libxslt1-dev
apt-get -y install libyaml-dev
apt-get -y install make
apt-get -y install nfs-common
apt-get -y install openssl
apt-get -y install patch
apt-get -y install pep8
apt-get -y install pkg-config
apt-get -y install portmap
apt-get -y install python-dev
apt-get -y install python-setuptools
apt-get -y install sqlite3
apt-get -y install tcl8.5
apt-get -y install tmux
apt-get -y install vim
apt-get -y install zlib1g
apt-get -y install zlib1g-dev

# Ensure the database is started
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

su - vagrant <<-'EOF'
  cd ~/web
  bundle check || bundle install
  # Force the app to use the internal Postgres port number and ignore .env
  bundle exec rake db:migrate
  bundle exec rake db:test:prepare
EOF
