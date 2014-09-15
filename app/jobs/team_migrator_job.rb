#TODO DELETE ME
class TeamMigratorJob
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(id)
    Rails.logger.info("perform(#{id})")

    team = Team.find(id)
    if pgteam = find_or_initialize_team(id, team)
      extract_account(pgteam, team)

      extract_locations(pgteam, team)
      extract_links(pgteam, team)
      add_members(pgteam)
      add_jobs(pgteam)
      convert_followers(pgteam)
      add_pending_requests(pgteam, team)
    end
  end


  private

  def find_or_initialize_team(id, team)
    Rails.logger.info("find_or_initialize_team(#{id}, #{team.id})")

    begin
      PgTeam.find_or_initialize_by_mongo_id(id) do |pgteam|
        # pgteam.avatar                 = team.avatar
        pgteam.about                    = team.about
        pgteam.achievement_count        = team.achievement_count
        pgteam.analytics                = team.analytics
        pgteam.benefit_description_1    = team.benefit_description_1
        pgteam.benefit_description_2    = team.benefit_description_2
        pgteam.benefit_description_3    = team.benefit_description_3
        pgteam.benefit_name_1           = team.benefit_name_1
        pgteam.benefit_name_2           = team.benefit_name_2
        pgteam.benefit_name_3           = team.benefit_name_3
        pgteam.big_image                = team.big_image
        pgteam.big_quote                = team.big_quote
        pgteam.blog_feed                = team.blog_feed
        pgteam.branding                 = team.branding
        pgteam.country_id               = team.country_id
        pgteam.created_at               = team.created_at
        pgteam.endorsement_count        = team.endorsement_count
        pgteam.facebook                 = team.facebook
        pgteam.featured_banner_image    = team.featured_banner_image
        pgteam.featured_links_title     = team.featured_links_title
        pgteam.github                   = team.github
        pgteam.github_organization_name = team.github_organization_name
        pgteam.headline                 = team.headline
        pgteam.hide_from_featured       = team.hide_from_featured
        pgteam.highlight_tags           = team.highlight_tags
        pgteam.hiring_tagline           = team.hiring_tagline
        pgteam.interview_steps          = team.interview_steps
        pgteam.invited_emails           = team.invited_emails
        pgteam.link_to_careers_page     = team.link_to_careers_page
        pgteam.location                 = team.location
        pgteam.mean                     = team.mean
        pgteam.median                   = team.median
        pgteam.monthly_subscription     = team.monthly_subscription
        pgteam.name                     = team.name
        pgteam.number_of_jobs_to_show   = team.number_of_jobs_to_show
        pgteam.office_photos            = team.office_photos
        pgteam.organization_way         = team.organization_way
        pgteam.organization_way_name    = team.organization_way_name
        pgteam.organization_way_photo   = team.organization_way_photo
        pgteam.our_challenge            = team.our_challenge
        pgteam.paid_job_posts           = team.paid_job_posts
        pgteam.pending_join_requests    = team.pending_join_requests
        pgteam.premium                  = team.premium
        pgteam.preview_code             = team.preview_code
        pgteam.reason_description_1     = team.reason_description_1
        pgteam.reason_description_2     = team.reason_description_2
        pgteam.reason_description_3     = team.reason_description_3
        pgteam.reason_name_1            = team.reason_name_1
        pgteam.reason_name_2            = team.reason_name_2
        pgteam.reason_name_3            = team.reason_name_3
        pgteam.score                    = team.score
        pgteam.size                     = team.size
        pgteam.slug                     = team.slug
        pgteam.stack_list               = team.stack_list
        pgteam.total                    = team.total
        pgteam.twitter                  = team.twitter
        pgteam.upcoming_events          = team.upcoming_events
        pgteam.updated_at               = team.updated_at
        pgteam.upgraded_at              = team.upgraded_at
        pgteam.valid_jobs               = team.valid_jobs
        pgteam.website                  = team.website
        pgteam.why_work_image           = team.why_work_image
        pgteam.your_impact              = team.your_impact
        pgteam.youtube_url              = team.youtube_url

        pgteam.save!
      end
    rescue ActiveRecord::RecordInvalid => ex
      Rails.logger.error("[find_or_initialize_team(#{id}, #{team.id})] #{ex} >>\n#{ex.backtrace.join("\n  ")}")

      false
    end
  end

  def extract_account(pgteam, team)
    Rails.logger.info("extract_account(#{pgteam.id}, #{team.id})")

    return unless account = team.account
    return if pgteam.account
    begin
      pgaccount = pgteam.build_account(
        stripe_card_token: account.stripe_card_token,
        stripe_customer_token: account.stripe_customer_token,
        admin_id: account.admin_id
      )
      pgaccount.plans << Plan.where(id: account.plan_ids)
      pgaccount.save!
    rescue ActiveRecord::RecordInvalid => ex
      Rails.logger.error("[extract_account(#{pgteam.id}, #{team.id})] #{ex} >>\n#{ex.backtrace.join("\n  ")}")

      Rails.logger.ap(pgteam, :error)
      Rails.logger.ap(team, :error)

      # @just3ws, uncomment the following line and get all ID of the corrupted accounts
      raise ex

      false
    end

  end

  def extract_locations(pgteam, team)
    Rails.logger.info("extract_locations(#{pgteam.id}, #{team.id})")

    locations = team.team_locations
    return unless locations.any?
    return if pgteam.locations.any?
    locations.each do |location|
      pgteam.locations.create!(
        name:        location.name,
        description: location.description,
        address:     location.address,
        city:        location.city,
        state_code:  location.state_code,
        country:     location.country
      )
    end
  end

  def extract_links(pgteam, team)
    Rails.logger.info("extract_links(#{pgteam.id}, #{team.id})")

    links = team.featured_links
    return if  links.empty?
    return if pgteam.links.any?
    links.each do |link|
      pgteam.links.create! name: link.name,
        url: link.url
    end
  end

  def add_members(pgteam)
    Rails.logger.info("add_members(#{pgteam.id})")

    users = User.where(team_document_id: pgteam.mongo_id)
    users.each do |user|
      pgteam.members.create! user: user, state: 'active'
    end
    users.update_all(team_id: pgteam.id)
  end

  def add_jobs(pgteam)
    Rails.logger.info("add_jobs(#{pgteam.id})")

    Opportunity.where(team_document_id: pgteam.mongo_id).update_all(team_id: pgteam.id)
  end

  def convert_followers(pgteam)
    Rails.logger.info("convert_followers(#{pgteam.id})")

    FollowedTeam.where(team_document_id: pgteam.mongo_id).update_all(team_id: pgteam.id)
  end

  def add_pending_requests(pgteam, team)
    Rails.logger.info("add_pending_requests(#{pgteam.id}, #{team.id})")

    pending_team_members = team.pending_team_members
    return if pending_team_members.empty?
    pending_team_members.each do |pending_team_member|
      user = User.find pending_team_member.user_id
      pgteam.members.create user: user,
        created_at: pending_team_member.created_at,
        updated_at: pending_team_member.updated_at
    end
  end
end
