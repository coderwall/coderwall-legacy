namespace :facts do
  # PRODUCTION: RUNS DAILY
  task system: :environment do
    puts "Ashcat"
    Ashcat.perform
  end
end
