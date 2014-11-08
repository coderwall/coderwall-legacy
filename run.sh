vagrant up
vagrant ssh -c ". /home/vagrant/web/vagrant/run"

#export DOCKER_HOST=tcp://192.168.59.103:2376
#echo $DOCKER_HOST

#export DOCKER_CERT_PATH=/Users/mike/.boot2docker/certs/boot2docker-vm
#echo $DOCKER_CERT_PATH

#export DOCKER_TLS_VERIFY=1
#echo $DOCKER_TLS_VERIFY

#export REDIS_URL=redis://$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):6379
#echo $REDIS_URL

#export POSTGRES_URL=postgres://postgres@$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):5432/postgres
#echo $POSTGRES_URL

#export MONGO_URL=mongodb://$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):27017/badgify
#echo $MONGO_URL

#export DOCKER_DATABASE_URL=$POSTGRES_URL
#echo $DOCKER_DATABASE_URL

#fig build postgres redis mongo
#fig up -d postgres redis mongo

#rvm use ruby@coderwall --install --create
#bundle check || bundle install

#export RAILS_ENV=development
#export RACK_ENV=development

#bundle exec rake db:drop
#bundle exec rake db:create
#bundle exec rake db:migrate
#bundle exec rake db:test:prepare

#bundle exec rails server webrick -p 3000
