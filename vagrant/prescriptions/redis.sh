#!/bin/bash -x

REDIS_VERSION="2.8.3"

cd

apt-get -y install tcl8.5

rm -f redis-$REDIS_VERSION.tar.gz
rm -rf redis-$REDIS_VERSION

# Redis
wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar xzf redis-$REDIS_VERSION.tar.gz
cd redis-$REDIS_VERSION
make test
make
make install
cd utils
yes | sudo ./install_server.sh

