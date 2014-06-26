web: bundle exec puma -c ./config/puma.rb
worker: env QUEUE=CRITICAL,HIGH,MEDIUM,LOW,LOWER bundle exec rake resque:work
scheduler: bundle exec rake resque:scheduler
refresher: env QUEUE=REFRESH bundle exec rake resque:work
mailer: env QUEUE=mailer,digest_mailer bundle exec rake resque:work
