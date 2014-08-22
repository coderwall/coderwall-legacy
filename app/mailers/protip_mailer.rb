class ProtipMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper

  add_template_helper(UsersHelper)
  add_template_helper(ProtipsHelper)
  add_template_helper(ApplicationHelper)

  default_url_options[:host] = 'coderwall.com'
  default_url_options[:only_path] = false
  default from: '"Coderwall" <support@coderwall.com>'

  SPAM_NOTICE = "You're receiving this email because you signed up for Coderwall. We hate spam and make an effort to keep notifications to a minimum. To change your notification preferences, you can update your email settings here: http://coderwall.com/settings#email or immediately unsubscribe by clicking this link %unsubscribe_url%"
  STARS = {
    protip_upvotes: 'pro tip upvotes',
    followers: 'followers',
    endorsements: 'endorsements',
    protips_count: 'protips'
  }

  #################################################################################
  def popular_protips(user, protips, from, to)
    fail "Protips are required." if protips.nil? || protips.empty?
    headers['X-Mailgun-Campaign-Id'] = 'coderwall-popular_protips'

    @user = user
    @protips = protips
    @team, @job = get_team_and_job_for(@user)
    @issue = campaign_params

    stars = @user.following_users.where('last_request_at > ?', 1.month.ago)
    @star_stat = star_stat_for_this_week
    @star_stat_string = STARS[@star_stat]

    @most = star_stats(stars).sort_by { |star| -star[@star_stat] }.first
    @most = nil if @most && (@most[@star_stat] <= 0)

    mail to: 'mike@just3ws.com', subject: 'Popular Protips on Coderwall'
  end
  #################################################################################

  def campaign_params
    {
      utm_campaign: 'coderwall-popular_protips',
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

  def get_team_and_job_for(user)
    if user.team.try(:hiring?)
      [user.team, user.team.jobs.sample]
    else
      teams = teams_for_user(user)
      teams.each do |team|
        best_job = team.best_positions_for(user).detect do |job|
          (job.team_document_id == user.team_document_id) || !already_sent?(job, user)
        end
        return [team, best_job] unless best_job.nil?
      end
    end
    [nil, nil]
  end

  def teams_for_user(user)
    Team.most_relevant_featured_for(user).select do |team|
      team.hiring?
    end
  end

  def already_sent?(mailable, user)
    SentMail.where(user_id: user.id, mailable_id: mailable.id, mailable_type: mailable.class.name).exists?
  end

  module Queries
    def self.popular_protips(from, to)
      search_results = ProtipMailer::Queries.search_for_popular_protips(from, to)
      public_ids = search_results.map { |protip| protip['public_id'] }

      Protip.eager_load(:user, :comments).where("public_id in (?)", public_ids)
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
