namespace :leftronic do

  # PRODUCTION: RUNS DAILY
  task :all => [:au, :features_seen, :todays_most_active_users, :queue_size, :weekly_growth_rate, :total_users, :original_protips, :latest_team_updates, :comments]

  task :queue_size => :environment do
    queue_sizes = Resque.queues.to_a.inject({}) { |h, queue| h[queue.downcase] = Resque.size(queue); h }
    leftronic.leaderboard 'queue_sizes', [queue_sizes]
  end

  task :features_seen => :environment do
    leftronic.number "number_seen_teams", User.that_have_seen(:teams)
    leftronic.number "number_seen_jobs", User.that_have_seen(:jobs)
    leftronic.number "number_seen_product_description", User.that_have_seen(:product_description)
  end

  task :comments => :environment do
    leftronic.number "total_comments", Comment.count
    leftronic.number "todays_total_comments", Comment.where("created_at > ?", 24.hours.ago).count
    leftronic.list 'latest_comments', Comment.latest_comments_as_strings(10)
  end

  task :latest_team_updates => :environment do
    leftronic.list 'latest_team_updates', Team.order_by(:updated_at => 'desc').limit(10).map(&:slug)
  end

  task :purchased_bundles => :environment do
    leftronic.number 'purchased_bundles', PurchasedBundle.count
    leftronic.number 'gross_revenue', PurchasedBundle.sum(:total_amount).to_f / 100
    leftronic.number 'net_revenue', PurchasedBundle.sum(:coderwall_proceeds).to_f / 100
  end

  task :au => :environment do
    leftronic.number 'dau', percent_of_users_visited(24.hours.ago)
    leftronic.number 'wau', percent_of_users_visited(7.days.ago)
    leftronic.number 'mau', percent_of_users_visited(31.days.ago)
  end

  task :todays_most_active_users => :environment do
    leftronic.list 'most_active_users_today', Usage.top_ten_users_today.collect(&:username)
  end

  task :weekly_growth_rate => :environment do
    users_signedup_this_week = User.where("created_at >= ?", 7.days.ago).count
    leftronic.number 'weekly_growth_rate', (users_signedup_this_week.to_f / User.count.to_f) * 100
  end

  task :total_users => :environment do
    leftronic.number 'total_users', User.count
  end

  task :todays_organic_signups_percentage => :environment do
    leftronic.number 'os', percentage_of_organic_signups(24.hours.ago)
  end

  task :todays_original_protips_percentage => :environment do
    leftronic.number 'op', percentage_of_original_protips(24.hours.ago)
  end

  task :todays_top_protips => :environment do
    leftronic.list 'top_protips_today', Protip.search_trending_by_date(nil, Date.today, 1, 3).collect { |p| Rails.application.routes.url_helpers.protip_path(p.public_id) }
  end

  task :original_protips => :environment do
    leftronic.number 'original_protips', Protip.where(:created_by => "self").count
  end

  def leftronic
    @leftronic ||= Leftronic.new(ENV['LEFTRONIC_KEY'])
  end

  def percent_of_users_visited(since)
    count_since = User.where("last_request_at >= ?", since).count
    (count_since.to_f / User.count.to_f * 100)
  end

  def percentage_of_organic_signups(since)
    referred_signups = User.where('referred_by IS NOT NULL').where("created_at > ? ", since).count
    signups = User.where("created_at > ?", since).count
    (referred_signups * 100 / signups.to_f rescue 0).round(2)
  end

  def percentage_of_original_protips(since)
    original_protips_created = Protip.where("created_at > ?", since).reject(&:created_automagically?).count
    protips_created = Protip.where("created_at > ?", since).count
    (original_protips_created * 100 / protips_created.to_f rescue 0).round(2)
  end
end
