#!/bin/bash -x
export DEBIAN_FRONTEND=noninteractive

# Ensure the database is started
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

sudo su - vagrant <<-'EOF'
  cd ~/web
  bundle check && bundle install
  DEV_POSTGRES_PORT=5432 bundle exec rake db:migrate
  DEV_POSTGRES_PORT=5432 bundle exec rake db:test:prepare
EOF
