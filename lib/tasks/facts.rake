namespace :facts do
  # PRODUCTION: RUNS DAILY
  task system: :environment do
    puts "Changelogd"
    Changelogd.refresh
    puts "Ashcat"
    Ashcat.perform
  end
end
