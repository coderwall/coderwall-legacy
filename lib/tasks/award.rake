require 'awards'

namespace :award do
  namespace :activate do
    # PRODUCTION: RUNS DAILY
    task :active => :environment do
      User.pending.where('last_request_at > ?', 1.week.ago).find_each(:batch_size => 1000) do |user|
        Resque.enqueue(ActivateUser, user.username, always_activate=false)
      end
    end

    #task :now => :environment do
      #username = ENV["USER"]
      #raise "Must supply a username (USER=username)" if username.blank?
      #ActivateUser.new(username).perform
    #end

    #task :async => :environment do
      #username = ENV["USER"]
      #raise "Must supply a username (USER=username)" if username.blank?
      #Resque.enqueue(ActivateUser, username)
    #end
  end

  #task :catchup => :environment do
    #badges = ENV['BADGES'].split(",")
    #badges = Badges.all.map(&:name) if badges.first == "*"
    #raise "Must supply list of badge classes (BADGES=Mongoose,Narwhal)" if badges.empty?

    #User.active.find_each(:batch_size => 1000) do |user|
      #Resque.enqueue(AwardUser, user.username, badges)
    #end
  #end

  #namespace :refresh do
    #task :now => :environment do
      #username = ENV["USER"]
      #raise "Must supply a username (USER=username)" if username.blank?
      #RefreshUser.new(username).perform
    #end

    #task :async => :environment do
      #username = ENV["USER"]
      #raise "Must supply a username (USER=username)" if username.blank?
      #Resque.enqueue(RefreshUser, username)
    #end

    ## PRODUCTION: RUNS DAILY
    #task :stale => :environment do
      #daily_count = User.count/10
      #User.active.order("last_refresh_at ASC").limit(daily_count).find_each do |user|
        #if user.last_refresh_at < 5.days.ago
          #Resque.enqueue(RefreshUser, user.username)
        #end
      #end
    #end

    #task :activity => :environment do
      #User.active.find_each(:batch_size => 1000) do |user|
        #Resque.enqueue(BuildActivityStream, user.username)
      #end
    #end
  #end

  #namespace :github do
    #task :remove, [:who] => :environment do |t, args|
      #who = args.who || "last_month"
      #users = get_users(who)
      #users.find_each(:batch_size => 1000) do |user|
        #user.join_badge_orgs = false
        #user.save
      #end
    #end

    #task :add, [:who] => :environment do |t, args|
      #who = args.who || "last_month"
      #users = get_users(who)
      #users.find_each(:batch_size => 1000) do |user|
        #user.join_badge_orgs = true
        #user.save
      #end
    #end

    #def get_users(who)
      #if who == 'last_month'
        #User.where('created_at > ?', 1.month.ago)
      #elsif who == 'last_three_months'
        #User.where('created_at > ?', 3.months.ago)
      #elsif who == 'last_six_months'
        #User.where('created_at > ?', 6.months.ago)
      #elsif who == 'all'
        #User.all
      #else
        #User.where(:github => who)
      #end
    #end
  #end
end
