namespace :facts do

  # PRODUCTION: RUNS DAILY
  task :system => :environment do
    puts "Changelogd"
    Changelogd.refresh
    puts "Ashcat"
    Ashcat.perform
    NodeKnockout.new(2011, '2011/09/06').reset!
    NodeKnockout.new(2012, '2012/11/17').reset!
  end

  namespace :node_knockout do
    task :import_2011 => :environment do
      NodeKnockout.new(2011, '2011/09/06').reset!
    end

    task :import_2012 => :environment do
      NodeKnockout.new(2012, '2012/11/17').reset!
    end
  end
end