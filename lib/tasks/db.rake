# PRODUCTION: RUNS DAILY
task :clear_expired_sessions => :environment do
  ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 7.days.ago])
end

#namespace :db do
  #namespace :download do
    #desc 'Kickoff a backup of the production database. Expires the oldest backup so don\'t go crazy.'
    #task :generate do
      #Bundler.with_clean_env do
        #sh("heroku pgbackups:capture --expire --app coderwall-production")
      #end
    #end

    #desc 'Fetch the last backup.'
    #task :latest do
      #Bundler.with_clean_env do
        #sh("curl `heroku pgbackups:url --app coderwall-production` -o latest.dump")
      #end
    #end

    #desc 'Overwrite the local database from the backup.'
    #task :load => :environment do
      #puts 'Cleaning out local database tables'
      #ActiveRecord::Base.connection.tables.each do |table|
        #puts "Dropping #{table}"
        #ActiveRecord::Base.connection.execute("DROP TABLE #{table};")
      #end

      #puts 'Loading Production database locally'
      #`pg_restore --verbose --clean --no-acl --no-owner -h localhost -d coderwall_development latest.dump`

      #puts '!!!!========= YOU MUST RESTART YOUR SERVER =========!!!!'
    #end

    #task :clean do
      #`rm latest.dump`
    #end
  #end

  #desc 'Fetch the production database and overwrite the local development database.'
  #task restore: %w{
                    #db:download:generate
                    #db:download:latest
                    #db:download:load
                    #db:download:clean
                    #db:migrate

                 #}
#end
