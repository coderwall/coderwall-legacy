namespace :teams do
  # PRODUCTION: RUNS DAILY
  task :refresh => [:recalculate]

  task :recalculate => :environment do
    Team.all.each do |team|
      ProcessTeamJob.perform_async('recalculate', team.id)
    end
  end


  #task :suspend_payment => :environment do
    #puts "Suspending #{ENV['slug']}"
    #t = Team.where(:slug => ENV['slug']).first
    #t.account.stripe_customer_token = nil
    #t.account.suspend!
    #t.valid_jobs = false
    #t.monthly_subscription = false
    #t.paid_job_posts = 0
    #t.save!
  #end

  #task :leadgen => :environment do
    #require 'csv'
    #CSV.open(filename = 'elasticsales.csv', 'w') do |csv|
      #csv << header_row = ['Team Name', 'Team URL', 'Name', 'Title', 'Email', 'Profile', 'Score', 'Last Visit', 'Last Email', 'Joined', 'Login Count', 'Country', 'City', 'Receives Newsletter']
      #Team.all.each do |team|
        #if team.number_of_completed_sections(remove_protips = 'protips') >= 3 && !team.hiring?
          #puts "Processing: #{team.name}"
          #team.team_members.each do |m|
            #csv << [team.name, "https://coderwall.com/team/#{team.slug}",
                    #m.display_name,
                    #m.title,
                    #m.email,
                    #"https://coderwall.com/#{m.username}",
                    #m.score_cache.to_i,
                    #m.last_request_at,
                    #m.last_email_sent,
                    #m.created_at,
                    #m.login_count,
                    #m.country,
                    #m.city,
                    #m.receive_newsletter]
          #end
        #end
      #end
    #end
  #end

  #task :killleaderboard => :environment do
    #REDIS.del(Team::LEADERBOARD_KEY)
  #end

  #task :reindex => :environment do
    #enqueue(ProcessTeam, :reindex, Team.first.id)
  #end

  #task :expire_jobs => :environment do
    #Team.featured.each do |team|
      #unless team.premium?
        #enqueue(DeactivateTeamJobs, team.id.to_s)
      #end
    #end
  #end

  #namespace :hiring do

    #task :coderwall => :environment do
      ## {$or:[{"website": /career|job|hiring/i}, {"about": /career|job|hiring/i}]}
      #matcher = /career|job|hiring/i
      #matching = []
      #[Team.where(:website => matcher).all,
       #Team.where(:about => matcher).all].flatten.each do |team|
        #matching << team
        #puts "#{team.name}: http://coderwall.com/team/#{team.slug}"
      #end
    #end

    #task :authenticjobs => :environment do
      #0.upto(10) do |page|
        #positions = JSON.parse(RestClient.get("http://www.authenticjobs.com/filter.php?page=#{page}&page_size=50&location=&onlyremote=0&search=&category=0&types=1%2C2%2C3%2C4"))
        #positions['listings'].each do |position|
          #company = position['company']
          #team = Team.where(:name => /#{company}/i).first
          #fields = [scrub(company)]
          #fields << (team.nil? ? nil : "http://coderwall/team/#{team.slug}")
          #fields << scrub(position['title'])
          #fields << scrub(position['loc'])
          #fields << DateTime.strptime(position['post_date'].to_s, '%s').to_s.split('T').first
          #fields << "http://www.authenticjobs.com/#{position['url_relative']}"
          #puts fields.join(', ')
        #end
      #end
    #end

    #task :github => :environment do
      ## positions = Nokogiri::HTML(open('https://jobs.github.com/positions'))
      #0.upto(5) do |page|
        #positions = JSON.parse(RestClient.get("https://jobs.github.com/positions.json?page=#{page}"))
        #positions.each do |position|
          #company = position['company']
          #team = Team.where(:name => /#{company}/i).first
          #fields = [scrub(company)]
          #fields << (team.nil? ? nil : "http://coderwall/team/#{team.slug}")
          #fields << scrub(position['title'])
          #fields << scrub(position['location'])
          #fields << position['created_at']
          #fields << position['url']
          #puts fields.join(', ')
        #end
      #end
    #end

    #def scrub(val)
      #val.gsub(/, |,/, ' - ')
    #end
  #end
end
