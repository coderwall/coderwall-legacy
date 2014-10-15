namespace :db do

  task smash: %w(redis:flush db:schema:load db:test:prepare db:seed)

  namespace :download do
    def db_dump_file
      `mkdir -p /home/vagrant/tmp`
      '/home/vagrant/tmp/coderwall-production.dump'
    end

    desc 'Create a production database backup'
    task :generate do
      Bundler.with_clean_env do
        sh("heroku pgbackups:capture --expire --app #{ENV['HEROKU_APP_NAME']}")
      end
    end

    desc 'Download latest database backup'
    task :latest do
      Bundler.with_clean_env do
        sh("curl `heroku pgbackups:url --app #{ENV['HEROKU_APP_NAME']}` -o #{db_dump_file}")
      end
    end

    desc 'Load local database backup into dev'
    task load: :environment do
      raise 'local dump not found' unless File.exists?(db_dump_file)

      puts 'Cleaning out local database tables'
      ActiveRecord::Base.connection.tables.each do |table|
        puts "Dropping #{table}"
        ActiveRecord::Base.connection.execute("DROP TABLE #{table};")
      end

      puts 'Loading Production database locally'
      `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d coderwall_development #{db_dump_file}`

      puts '!!!!========= YOU MUST RESTART YOUR SERVER =========!!!!'
    end

    task :clean do
      `rm #{db_dump_file}`
    end
  end

  task restore: %w(db:download:generate db:download:latest db:download:load db:download:clean db:migrate)

  desc 'ActiveRecord can you shut up for 30 minutes?'
  task mute: :environment do
    ActiveRecord::Base.logger = nil
  end
end
