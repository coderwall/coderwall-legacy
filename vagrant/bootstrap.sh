#!/bin/bash -x
export DEBIAN_FRONTEND=noninteractive

# Ensure the database is started
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

su - vagrant <<-'EOF'
  cd ~/web
  bundle check || bundle install
  # Force the app to use the internal Postgres port number and ignore .env
  bundle exec rake db:migrate
  bundle exec rake db:test:prepare
EOF
