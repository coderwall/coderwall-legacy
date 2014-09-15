require File.expand_path('../config/application', __FILE__)
require 'rake'

Coderwall::Application.load_tasks

task default: :spec


namespace :team do
  task migrate: :environment do
    TeamMigratorBatchJob.new.perform
  end

  #
  # IMPORTANT: pending_join_requests is a STRING array in Postgres but an INTEGER array in MongoDB.
  # IMPORTANT: pending_join_requests is an array of User#id values
  #

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

  task verify: :environment do
    PgTeam.find_each(batch_size: 100) do |pg_team|
      begin
        mongo_id = pg_team.mongo_id
        mongo_team = Team.find(mongo_id)

        # Ignoring:
        # - updated_at

        # Team
        %i(median score total slug mean pending_join_requests).each do |attr|
          neq(attr, pg_team, mongo_team, false)
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

        # TODO: Locations

        # TODO: Links

        # TODO: Members

        # TODO: Jobs

        # TODO: Followers

        # TODO: Pending Requests

      end
    end
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
