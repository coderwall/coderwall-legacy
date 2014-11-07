require File.expand_path('../config/application', __FILE__)
require 'rake'

Coderwall::Application.load_tasks

task default: :spec

namespace :team do
  task migrate: :environment do
    puts '--- Beginning team migration ---'
    success = true
    begin
      Team.each do |team|
        begin
          puts ">>> Migrating #{team.id}"
          TeamMigratorJob.new.perform(team.id.to_s)
        rescue => ex
          success = false
          puts "[#{team.id.to_s}] #{ex} >>\n#{ex.backtrace.join("\n  ")}"
        end
      end
    ensure
      puts "--- #{success ? 'Successful' : 'Unsuccessful'} team migration ---"
    end
  end

  #
  # IMPORTANT: pending_join_requests is a STRING array in Postgres but an INTEGER array in MongoDB.
  # IMPORTANT: pending_join_requests is an array of User#id values
  #

  task verify: :environment do
    ActiveRecord::Base.logger = nil
    Mongoid.logger = nil
    Moped.logger = nil

    PgTeam.find_each(batch_size: 100) do |pg_team|
      begin
        mongo_id = pg_team.mongo_id
        mongo_team = Team.find(mongo_id)

        # Ignoring:
        # - updated_at

        puts 'TEAM'

        neq(:slug, pg_team, mongo_team, false)

        neq_string(:pending_join_requests, pg_team, pg_team.pending_join_requests.map(&:to_i).sort.join(', '), mongo_team, mongo_team.pending_join_requests.map(&:to_i).sort.join(', '), false)

        %i(score size total mean median).each do |attr|
          neq_dec(attr, pg_team, mongo_team, false)
        end

        %i(about achievement_count analytics benefit_description_1 benefit_description_2 benefit_description_3 benefit_name_1 benefit_name_2 benefit_name_3 big_image big_quote blog_feed branding country_id created_at endorsement_count facebook featured_banner_image featured_links_title github github_organization_name headline hide_from_featured highlight_tags hiring_tagline interview_steps invited_emails link_to_careers_page location monthly_subscription name number_of_jobs_to_show office_photos organization_way organization_way_name organization_way_photo our_challenge paid_job_posts premium preview_code reason_description_1 reason_description_2 reason_description_3 reason_name_1 reason_name_2 reason_name_3 size stack_list twitter upcoming_events upgraded_at valid_jobs website why_work_image your_impact youtube_url).each do |attr|
          neq(attr, pg_team, mongo_team)
        end

        # TODO: Account
        if mongo_team.account.present? && pg_team.account.blank?
          puts "account | pg:#{pg_team.id} | mongo:#{mongo_team.id}| The account was not migrated."
        end

        if mongo_team.account.present? && pg_team.account.present?
          check_plans = %i(stripe_card_token stripe_customer_token admin_id).map do |attr|
            neq(attr, pg_team.account, mongo_team.account)
          end.any? { |x| !x }

          # TODO: Plans
          if check_plans
            left = pg_team.account.plans.pluck(:id).sort
            right = mongo_team.account.plan_ids.sort

            if left != right
              puts "account.plans | pg:#{pg_team.id} | mongo:#{mongo_team.id}| #{left} != #{right}"
            end
          end
        end

        #puts 'LOCATIONS'

        #pg_team_locations = pg_team.locations
        #mongo_team_locations =  mongo_team.team_locations

        #if mongo_team_locations.count != pg_team_locations.count
          #puts "locations | pg:#{pg_team.id} | mongo:#{mongo_team.id}| #{mongo_team_locations.count} != #{pg_team_locations.count}"
        #end

        ## Ignoring:
        ## - points_of_interest
        #pg_team.locations.each do |pg_team_location|
          #mongo_team_location = mongo_team.team_locations.select { |tl| tl.name == pg_team_location.name }.first

          #%i(address city country description name state_code).each do |attr|
            #neq(attr, pg_team_location, mongo_team_location, false)
          #end
        #end


        #puts 'LINKS'

        pg_team_links = pg_team.links
        mongo_team_links = mongo_team.featured_links

        if mongo_team_links.count != pg_team_links.count
          puts "links | pg:#{pg_team.id} | mongo:#{mongo_team.id}| #{mongo_team_links.count} != #{pg_team_links.count}"
        end

        pg_team_links.each do |pg_team_link|
          mongo_team_link = mongo_team_links.select { |tl| tl.name == pg_team_link.name }.first

          %i(url name).each do |attr|
            neq(attr, pg_team_link, mongo_team_link, false)
          end
        end

        #puts 'MEMBERS'

        if pg_team.members.count != mongo_team.team_members.count
          puts "members | pg:#{pg_team.id} | mongo:#{mongo_team.id}| #{pg_team.members.count} < #{mongo_team.team_members.count}"
        end


        #puts 'JOBS'

        #pg_team.jobs.each do |pg_team_job|
          #mongo_team_job = Team.where(id: pg_team_job.team_document_id.to_s).first

          #neq(:name, pg_team_job, mongo_team_job, false)
        #end

        #puts 'FOLLOWERS'

        pg_team.followers.each do |pg_team_follower|
          mongo_team_follower = Team.where(id: pg_team_follower.mongo_id.to_s).first
          # admins
          # editors
          %i(
            about
            achievement_count
            analytics
            benefit_description_1
            benefit_description_2
            benefit_description_3
            benefit_name_1
            benefit_name_2
            benefit_name_3
            big_image
            big_quote
            blog_feed
            branding
            country_id
            created_at
            endorsement_count
            facebook
            featured_banner_image
            featured_links_title
            github_organization_name
            headline
            hide_from_featured
            highlight_tags
            hiring_tagline
            interview_steps
            invited_emails
            link_to_careers_page
            location
            monthly_subscription
            name
            number_of_jobs_to_show
            office_photos
            organization_way
            organization_way_name
            organization_way_photo
            our_challenge
            paid_job_posts
            premium
            preview_code
            reason_description_1
            reason_description_2
            reason_description_3
            reason_name_1
            reason_name_2
            reason_name_3
            slug
            stack_list
            twitter
            upcoming_events
            upgraded_at
            valid_jobs
            website
            why_work_image
            your_impact
            youtube_url
          ).each do |attr|
            neq(attr, pg_team_follower, mongo_team_follower, false)
          end
          neq_string(:pending_join_requests, pg_team_follower, pg_team_follower.pending_join_requests.map(&:to_i).sort.join(', '), mongo_team_follower, mongo_team_follower.pending_join_requests.map(&:to_i).sort.join(', '), false)

          neq_string(:avatar, pg_team_follower, pg_team_follower.avatar.url, mongo_team_follower, mongo_team_follower.avatar.url, false)

          %i(score size total mean median).each do |attr|
            neq_dec(attr, pg_team_follower, mongo_team_follower, false)
          end
        end

        # TODO: Pending Requests
      end
    end
  end

  def neq(attr, pg, mongo, fail_if_neq=true)
    left =  pg.send(attr)
    right = mongo.send(attr)

    if left != right
      puts "#{attr} | pg:#{pg.id} | mongo:#{mongo.id}| #{left} != #{right}"
      true
    else
      false
    end
  rescue => ex
    print_neq_error(ex)
  end

  def neq_string(attr, pg, left, mongo, right, fail_if_neq=true)
    if left != right
      puts "#{attr} | pg:#{pg.id} | mongo:#{mongo.id}| #{left} != #{right}"
      true
    else
      false
    end
  rescue => ex
    print_neq_error(ex)
  end

  def neq_dec(attr, pg, mongo, fail_if_neq=true)
    scale = 7

    left =  pg.send(attr).to_d.round(scale)
    right = mongo.send(attr).to_d.round(scale)


    if left != right
      puts "#{attr} | pg:#{pg.id} | mongo:#{mongo.id}| #{left} != #{right}"
      true
    else
      false
    end
  rescue => ex
    print_neq_error(ex)
  end

  def print_neq_error(ex)
    puts '*'*80
    puts
    puts ex
    puts
    puts '-'*80
    puts
    ap ex.backtrace
    puts
    puts '*'*80

    require 'pry'; binding.pry
  end

  task counts: :environment do
    pg_team_count = PgTeam.count
    puts "PgTeam.count=#{pg_team_count}"
    team_count = Team.count
    puts "Team.count=#{team_count}"
    puts "Unmigrated teams count=#{(team_count - pg_team_count)}"
  end


  task unmigrated: :environment do
    unmigrated_teams = []

    Team.all.each do |team|
      unmigrated_teams << team.id.to_s unless PgTeam.where(mongo_id: team.id.to_s).exists?
    end

    puts "Unmigrated teams count=#{unmigrated_teams.count}"
    puts "Unmigrated Teams=%w(#{unmigrated_teams.join(' ')})"
  end
end
