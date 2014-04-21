bundle exec rake tmp:clear
bundle exec rake log:clear
bundle exec rake RAILS_ENV=production RAILS_GROUP=assets assets:clean
yes | rm -df public/assets
rm -df tmp/cache/assets
rm -df tmp/cache/sass
bundle exec rails runner 'Rails.cache.clear'
