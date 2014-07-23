class WeeklyDigest < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActiveSupport::Benchmarkable
  add_template_helper(UsersHelper)
  add_template_helper(ProtipsHelper)
  add_template_helper(ApplicationHelper)

  def self.queue
    :digest_mailer
  end

  default_url_options[:host] = "coderwall.com"
  default_url_options[:only_path] = false
  default from: '"Coderwall" <support@coderwall.com>'

  SPAM_NOTICE = "You're receiving this email because you signed up for Coderwall. We hate spam and make an effort to keep notifications to a minimum. To change your notification preferences, you can update your email settings here: http://coderwall.com/settings#email or immediately unsubscribe by clicking this link %unsubscribe_url%"


  WEEKLY_DIGEST_EVENT = 'weekly_digest'
  ACTIVITY_SUBJECT_PREFIX = "[Coderwall]"

  def weekly_digest(username)
    headers['X-Mailgun-Variables'] = {email_type: WEEKLY_DIGEST_EVENT}.to_json
    track_campaign(WEEKLY_DIGEST_EVENT)

    @user = User.find_by_username(username)
    since = [@user.last_request_at || Time.at(0), 1.week.ago].min

    benchmark "digest:stats" do
      @stats = @user.activity_stats(since, true).sort_by { |stat, count| -(count || 0) }
    end

    #@networks = @user.following_networks.most_protips
    @user.touch(:last_email_sent)
    @issue = weekly_digest_utm
    benchmark "digest:protips" do
      @protips = protips_for(@user, 6)
    end

    abort_delivery if @protips.blank? || @protips.count < 4

    benchmark "digest:stars" do
      @stars = @user.following_users.where('last_request_at > ?', 1.month.ago)
      @star_stat = star_stat_for_this_week
      @star_stat_string = STARS[@star_stat]
      @most = star_stats(@stars).sort_by { |star| -star[@star_stat] }.first
      @most = nil if @most && (@most[@star_stat] <= 0)
    end

    benchmark "digest:team" do
      @team, @job = get_team_and_job_for(@user)
    end

    benchmark "digest:mark_sent" do
      mark_sent(@job) unless @job.nil?
    end

    mail to: @user.email, subject: "#{ACTIVITY_SUBJECT_PREFIX} #{weekly_digest_subject_for(@user, @stats, @most)}"
  rescue Exception => e
    abort_delivery(e.message)
  end

  def abort_delivery(message="")
    #self.perform_deliveries = false
    Rails.logger.error "sending bad email:#{message}"
  end

  #if Rails.env.development?
    #class Preview < MailView

      #def weekly_digest
        #user = User.active.order("Random()").first
        #mail = ::WeeklyDigest.weekly_digest(user.username)
        #mail
      #end

    #end
  end

  private
  def track_campaign(id)
    headers['X-Mailgun-Campaign-Id'] = id
  end

  def benchmark(message, options={})
    Rails.env.development? ? super(message, options) : yield
  end

  def weekly_digest_subject_for(user, stats, most)
    stat_mention = (stats.first && (stats.first[1] >= 5) && "including #{stats.first[1]} new #{stats.first[0].to_s.humanize.downcase}") || nil
    "Your weekly brief #{stat_mention} "
  end

  def star_stats(stars, since=1.week.ago)
    stars.collect { |star| star.activity_stats(since, true) }.each_with_index.map { |stat, index| stat.merge(user: stars[index]) }
  end

  def protips_for(user, how_many=6)
    if user.last_request_at && user.last_request_at < 5.days.ago
      protips = Protip.trending_for_user(user).first(how_many)
      protips += Protip.trending.first(how_many-protips.count) if protips.count < how_many
    else
      protips =Protip.hawt_for_user(user).results.first(how_many)
      protips +=Protip.hawt.results.first(how_many) if protips.count < how_many
    end
    protips
  end

  def mark_all_sent(mailables)
    mailables.map { |mailable| mark_sent(mailable) }
  end

  def mark_sent(mailable)
    SentMail.create!(user: @user, sent_at: @user.last_email_sent, mailable: mailable)
  end

  def already_sent?(mailable, user)
    SentMail.where(user_id: user.id, mailable_id: mailable.id, mailable_type: mailable.class.name).exists?
  end

  STARS = {protip_upvotes: "pro tip upvotes", followers: "followers", endorsements: "endorsements", protips_count: "protips"}

  def star_stat_for_this_week
    STARS.keys[week_of_the_month % 4]
  end

  def week_of_the_month
    Date.today.cweek - Date.today.at_beginning_of_month.cweek
  end

  def teams_for_user(user)
    Team.most_relevant_featured_for(user).select { |team| team.hiring? }
  end

  def weekly_digest_utm
    {
        utm_campaign: "weekly_digest",
        utm_content: Date.today.midnight,
        utm_medium: "email"
    }
  end

  def get_team_and_job_for(user)
    if user.team.try(:hiring?)
      [user.team, user.team.jobs.sample]
    else
      teams = teams_for_user(user)
      teams.each do |team|
        best_job = team.best_positions_for(user).detect { |job| (job.team_document_id == user.team_document_id) or !already_sent?(job, user) }
        return [team, best_job] unless best_job.nil?
      end
    end
    [nil, nil]
  end
end
