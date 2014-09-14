# postinstall.sh created from Mitchell's official lucid32/64 baseboxes
# and then further defaced by just3ws to create the Coderwall devenv
for i in `seq 1 20`;
do
echo "Have you set the ENV keys?"
done

sleep 30


set -x

date > /etc/vagrant_box_build_time

# Set timezone to UTC
echo "Etc/UTC" | sudo tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r)
apt-get -y install build-essential

# General dependencies and tools just... mashed, just mashed all together.
apt-get -y install ack-grep autoconf automake bison ca-certificates         \
                   curl g++ gcc git-core htop iotop libc6-dev libffi-dev    \
                   libgdbm-dev libncurses5-dev libopenssl-ruby libreadline6 \
                   libreadline6-dev libsqlite3-0 libsqlite3-dev libssl-dev  \
                   libtool libxml2-dev libxslt-dev libyaml-dev make openssl \
                   patch pkg-config sqlite3 tmux vim zlib1g zlib1g-dev gawk \
                   libxml2-dev curl libcurl4-openssl-dev        \
                   imagemagick libmagickcore-dev libmagickwand-dev tcl8.5
apt-get -y install libcurl3 libcurl3-dev libcurl3-gnutls libcurl4-openssl-dev
apt-get -y install libpq-dev
apt-get -y install libxml2 libxml2-dev libxslt1-dev


# Install NFS client
apt-get -y install nfs-common portmap

# Apt-install python tools and libraries
# Install NFS client
# libpq-dev lets us compile psycopg for Postgres
apt-get -y install ack-grep
apt-get -y install autoconf
apt-get -y install automake
apt-get -y install bash
apt-get -y install bison
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

RUBY_VERSION="2.1.4"
wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-$RUBY_VERSION.tar.bz2
tar jxf ruby-$RUBY_VERSION.tar.bz2
cd ruby-$RUBY_VERSION
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-$RUBY_VERSION*
chown -R root:admin /opt/ruby
chmod -R g+w /opt/ruby

RUBYGEMS_VERSION="2.4.1"
wget http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz
tar xzf rubygems-$RUBYGEMS_VERSION.tgz
cd rubygems-$RUBYGEMS_VERSION
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-$RUBYGEMS_VERSION*

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Java7
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
TMPNAME=$(tempfile)
apt-get -y update >> /dev/null 2> $TMPNAME
PGPKEY=`cat $TMPNAME | cut -d":" -f6 | cut -d" " -f3`
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $PGPKEY
rm $TMPNAME
apt-get -y update
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer oracle-java7-set-default
echo "export JAVA_OPTS=\"-Xmx400m -XX:MaxPermSize=80M -XX:+UseCompressedOops -XX:+AggressiveOpts\"" >> /etc/profile.d/jdk.sh
echo "setenv JAVA_OPTS \"-Xmx400m -XX:MaxPermSize=80M -XX:+UseCompressedOops -XX:+AggressiveOpts\"" >> /etc/profile.d/jdk.csh

NODEJS_VERSION="0.10.31"
git clone https://github.com/joyent/node.git
cd node
git checkout v$NODE_VERSION
./configure --prefix=/usr
make
make install
cd ..
rm -rf node*


# Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc
/opt/ruby/bin/gem install bundler --no-ri --no-rdoc

# Add the Puppet group so Puppet runs without issue
groupadd puppet

# Install Foreman
/opt/ruby/bin/gem install foreman --no-ri --no-rdoc

POSTGRES_VERSION="9.3.3"
wget http://ftp.postgresql.org/pub/source/v$POSTGRES_VERSION/postgresql-$POSTGRES_VERSION.tar.bz2
tar jxf postgresql-$POSTGRES_VERSION.tar.bz2
cd postgresql-$POSTGRES_VERSION
./configure --prefix=/usr
make world
make install-world
cd ..
rm -rf postgresql-$POSTGRES_VERSION*

# Add 'vagrant' role
su -c 'createuser -s vagrant' postgres
su -c 'createuser -s coderwall' postgres

# Initialize postgres DB
useradd -p postgres postgres
mkdir -p /var/pgsql/data
chown postgres /var/pgsql/data
su -c "/usr/bin/initdb -D /var/pgsql/data --locale=en_US.UTF-8 --encoding=UNICODE" postgres
mkdir /var/pgsql/data/log
chown postgres /var/pgsql/data/log

# Set the PG instance to listen and accept connections from anywhere
echo "listen_addresses = '*'" | tee -a /var/pgsql/data/postgresql.conf
echo host all all  0.0.0.0/0 trust | tee -a  /var/pgsql/data/pg_hba.conf

# Start postgres
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

# Start postgres at boot
sed -i -e 's/exit 0//g' /etc/rc.local
echo "su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres" >> /etc/rc.local

# MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
apt-get -y update
apt-get -y install mongodb-10gen

REDIS_VERSION="2.8.4"
wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar xzf redis-$REDIS_VERSION.tar.gz
cd redis-$REDIS_VERSION
make test
make
make install
cd utils
yes | sudo ./install_server.sh
cd ../..
rm -rf ~/redis-$REDIS_VERSION

ES_VERSION="0.90.13"
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.deb
dpkg -i elasticsearch-$ES_VERSION.deb
rm -rf ~/elasticsearch-$ES_VERSION.deb

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin' > /etc/profile.d/vagrantruby.sh

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /home/vagrant
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Install Heroku toolbelt
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

# Set locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

# Configure the user.
su postgres -c 'createuser -s vagrant'
su postgres -c 'createuser -s coderwall'

su postgres -c 'pg_ctl stop -D /var/pgsql/data  2>&1'
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

sudo su - vagrant <<-'EOF'
  echo export EDITOR=vim >> $HOME/.bashrc
  echo insecure > $HOME/.curlrc
  echo progress-bar >> $HOME/.curlrc

  echo rvm_install_on_use_flag=1 >> $HOME/.rvmrc
  echo rvm_project_rvmrc=1 >> $HOME/.rvmrc
  echo rvm_trust_rvmrcs_flag=1 >> $HOME/.rvmrc

  curl -k -L https://get.rvm.io | bash -s stable --autolibs=install-packages
  source "$HOME/.rvm/scripts/rvm"
  [[ -s "$rvm_path/hooks/after_cd_bundle" ]] && chmod +x $rvm_path/hooks/after_cd_bundle
  rvm autolibs enable
  rvm requirements
  rvm reload

  _RUBY_VERSION=ruby-2.1.4
  rvm install $_RUBY_VERSION
  rvm gemset create coderwall
  rvm use $_RUBY_VERSION --default
  rvm use $_RUBY_VERSION@coderwall
  gem update --system && gem update bundler
  gem install curb -v '0.8.6'

  mkdir -p ~/tmp

  git clone https://github.com/assemblymade/coderwall.git ~/bootstrap/coderwall
  cd ~/bootstrap/coderwall
  rvm current

  bundle config --global jobs 3
  bundle install

  echo "IMPORTANT: Set the ENV Keys!!!
  export ENV_KEYS=somevalue

  bundle exec rake db:drop:all
  bundle exec rake db:create:all
  RAILS_ENV=test bundle exec rake db:create
  bundle exec rake db:schema:load
  bundle exec rake db:migrate
  bundle exec rake db:seed
  bundle exec rake db:test:prepare
EOF

# Install some libraries
apt-get -y clean
apt-get -y autoclean
apt-get -y autoremove

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v $(uname -r) | xargs apt-get -y purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
echo "==> Removing development packages"
#dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge
echo "==> Removing development tools"
dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y purge
apt-get -y purge cpp gcc g++
apt-get -y purge build-essential
echo "==> Removing default system Ruby"
apt-get -y purge ruby ri doc
echo "==> Removing default system Python"
apt-get -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30 python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl libffi5
echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

echo "==> Removing man pages"
rm -rf /usr/share/man/*
echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f
echo "==> Removing anything in /usr/src"
rm -rf /usr/src/*
echo "==> Removing any docs"
rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
exit
