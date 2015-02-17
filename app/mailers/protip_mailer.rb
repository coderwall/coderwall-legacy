class ProtipMailer < ApplicationMailer

  add_template_helper(UsersHelper)
  add_template_helper(ProtipsHelper)
  add_template_helper(ApplicationHelper)

  SPAM_NOTICE = "You're receiving this email because you signed up for Coderwall. We hate spam and make an effort to keep notifications to a minimum. To change your notification preferences, you can update your email settings here: http://coderwall.com/settings#email or immediately unsubscribe by clicking this link %unsubscribe_url%"
  STARS = {
    protip_upvotes: 'pro tip upvotes',
    followers: 'followers',
    endorsements: 'endorsements',
    protips_count: 'protips'
  }
  CAMPAIGN_ID = 'protip_mailer-popular_protips'
  POPULAR_PROTIPS_EVENT = 'coderwall-popular_protips'

  #################################################################################
  def popular_protips(user, protips, from, to)
    fail 'User is required.' unless user
    # Skip if this user has already been sent and email for this campaign id.
    fail "Already sent email to #{user.id} please check Redis SET #{CAMPAIGN_ID}." unless REDIS.sadd(CAMPAIGN_ID, user.id.to_s)

    fail 'Protips are required.' if protips.nil? || protips.empty?
    fail 'From date is required.' unless from
    fail 'To date is required.' unless to

    headers['X-Mailgun-Campaign-Id'] = CAMPAIGN_ID

    @user = user
    @protips = protips
    @team, @job = self.class.get_team_and_job_for(@user)
    unless @job.nil?
      self.class.mark_sent(@job, @user)
    end
    @issue = campaign_params

    stars = @user.following_users.where('last_request_at > ?', 1.month.ago)
    @star_stat = star_stat_for_this_week
    @star_stat_string = STARS[@star_stat]

    @most = star_stats(stars).sort_by do |star|
      -star[@star_stat]
    end.first
    @most = nil if @most && (@most[@star_stat] <= 0)

    mail(to: @user.email, subject: "It's #{Time.zone.now.strftime('%A')}")
  rescue Exception => ex
    abort_delivery(ex)
  end
  #################################################################################

  def abort_delivery(ex)
    Rails.logger.error("[ProtipMailer.popular_protips] Aborted email '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
  end

  def self.mark_sent(mailable, user)
    SentMail.create!(user: user, sent_at: user.last_email_sent, mailable: mailable)
  end

  def self.already_sent?(mailable, user)
    SentMail.where(user_id: user.id, mailable_id: mailable.id, mailable_type: mailable.class.name).exists?
  end

  def campaign_params
    {
      utm_campaign: POPULAR_PROTIPS_EVENT,
      utm_content: Date.today.midnight,
      utm_medium: 'email'
    }
  end

  def star_stat_for_this_week
    STARS.keys[week_of_the_month % 4]
  end

  def star_stats(stars, since=1.week.ago)
    stars.collect { |star| star.activity_stats(since, true) }.each_with_index.map { |stat, index| stat.merge(user: stars[index]) }
  end

  def week_of_the_month
    Date.today.cweek - Date.today.at_beginning_of_month.cweek
  end

  def self.get_team_and_job_for(user)
    if user.team.try(:hiring?)
      [user.team, user.team.jobs.sample]
    else
      teams = teams_for_user(user)
      teams.each do |team|
        best_job = team.best_positions_for(user).detect{|job| (job.team_id == user.team_id) or !already_sent?(job, user)}
        return [team, best_job] unless best_job.nil?
      end
    end
    [nil, nil]
  end

  def self.teams_for_user(user)
    Team.most_relevant_featured_for(user).select do |team|
      team.hiring?
    end
  end

  module Queries
    def self.popular_protips(from, to)
      search_results = ProtipMailer::Queries.search_for_popular_protips(from, to)
      public_ids = search_results.map { |protip| protip['public_id'] }

      Protip.eager_load(:user, :comments).where('public_id in (?)', public_ids)
    end

    def self.search_for_popular_protips(from, to, max_results=10)
      url = "#{ENV['ELASTICSEARCH_URL']}/#{ENV['ELASTICSEARCH_PROTIPS_INDEX']}/_search"
      query = {
        'query' => {
          'bool' => {
            'must' => [
              {
                'range' => {
                  'protip.created_at' => {
                    'from' => from.strftime('%Y-%m-%d'),
                    'to' => to.strftime('%Y-%m-%d')
                  }
                }
              }
            ]
          }
        },
        'size' => max_results,
        'sort' => [
          {
            'protip.popular_score' => {
              'order' => 'desc'
            }
          }
        ]
      }
      response = RestClient.post(url, MultiJson.dump(query), content_type: :json, accept: :json)
      # TODO: check for response code
      MultiJson.load(response.body)['hits']['hits'].map { |protip| protip['_source'] }
    end
  end
end
