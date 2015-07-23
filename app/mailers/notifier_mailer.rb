# TODO, Extract components
class NotifierMailer < ApplicationMailer
  add_template_helper(UsersHelper)
  add_template_helper(ProtipsHelper)
  add_template_helper(ApplicationHelper)
  add_template_helper(AccountsHelper)

  layout 'email', except: [:weekly_digest, :alert_admin]

  class NothingToSendException < Exception
  end

  SPAM_NOTICE = "You're receiving this email because you signed up for Coderwall. We hate spam and make an effort to keep notifications to a minimum. To change your notification preferences, you can update your email settings here: http://coderwall.com/settings#email or immediately unsubscribe by clicking this link %unsubscribe_url%"

  NEWSLETTER_EVENT = WELCOME_EVENT = 'welcome_email'
  ACTIVITY_EVENT = 'new_activity'
  FOLLOWER_EVENT = 'new_follower'
  RECIPT_EVENT = 'recipt_event'
  BADGE_EVENT = 'new_badge'
  NEW_COMMENT_EVENT = 'new_comment'
  NEW_APPLICANT_EVENT = 'new_applicant'
  INVOICE_EVENT = 'invoice'
  ACTIVITY_SUBJECT_PREFIX = '[Coderwall]'

  def welcome_email(user_id)
    headers['X-Mailgun-Variables'] = {email_type: WELCOME_EVENT}.to_json

    @user = User.find(user_id)
    @user.touch(:last_email_sent)

    if @user.created_at < 2.days.ago
      track_campaign('welcome_delayed')
    else
      track_campaign('welcome')
    end
    mail to: @user.email, subject: "Your coderwall welcome package"
  end

  def new_lead(username, email, company)
    @username = username
    @email = email
    @company = company
    mail to: 'sales@coderwall.com', subject: "[coderwall] New lead for enhanced team page!"
  end

  def new_activity(username)
    headers['X-Mailgun-Variables'] = {email_type: ACTIVITY_EVENT}.to_json
    track_campaign("activity_sent_#{Date.today.wday}")

    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)

    subject, @message = *activity_message_for_user(@user)

    mail to: @user.email, subject: "You've #{subject} on Coderwall!"
  end

  def new_badge(username)
    headers['X-Mailgun-Variables'] = {email_type: BADGE_EVENT}.to_json
    track_campaign("new_badge_earned")
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.reload
    @badge = next_badge_to_send(@user)

    unless @badge.nil?
      SentMail.create!(user: @user, sent_at: @user.last_email_sent, mailable: @badge)
      subject, @message = *new_badge_message_for_user(@user, @badge)
      mail to: @user.email, subject: "You've #{subject} on Coderwall!"
    else
      raise NothingToSendException.new
    end
  end

  def new_follower(username, follower_username)
    headers['X-Mailgun-Variables'] = {email_type: FOLLOWER_EVENT}.to_json
    track_campaign("new_follower")

    @follower = User.find_by_username(follower_username)
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)

    congratulation = %w{Awesome Brilliant Epic Sweet}.sample

    mail to: @user.email, subject: "#{congratulation}! You have a new fan on Coderwall"
  end

  def new_comment(user_id, commentor_id, comment_id)
    headers['X-Mailgun-Variables'] = {email_type: NEW_COMMENT_EVENT}.to_json
    track_campaign("new_comment")

    @commentor = User.find(commentor_id)
    @user = User.find(user_id)
    @comment = Comment.find(comment_id)
    @user.touch(:last_email_sent)

    SentMail.create!(user: @user, sent_at: @user.last_email_sent, mailable: @comment)

    mail to: @user.email, subject: "#{ACTIVITY_SUBJECT_PREFIX} #{@commentor.username} commented on your pro tip"
  end

  def comment_reply(username, commentor_username, comment_id)
    headers['X-Mailgun-Variables'] = {email_type: NEW_COMMENT_EVENT}.to_json
    track_campaign("new_comment")

    @commentor = User.find_by_username(commentor_username)
    @user = User.find_by_username(username)
    @comment = Comment.find(comment_id)
    @user.touch(:last_email_sent)

    SentMail.create!(user: @user, sent_at: @user.last_email_sent, mailable: @comment)

    mail to: @user.email, subject: "#{ACTIVITY_SUBJECT_PREFIX} #{@commentor.username} replied to your comment on a pro tip"
  end

  def authy(username)
    @user = User.find_by_username(username)
    congratulation = %w{Awesome Brilliant Epic Sweet}.sample
    name = @user.short_name
    mail to: @user.email, subject: "[Coderwall] #{congratulation} #{name}! You have a new fan and they've sent you a message"
  end

  def remind_to_create_team(username)
    track_campaign('remind_to_create_team')
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.touch(:remind_to_create_team)

    @subject = "Hey #{@user.short_name}, just a quick reminder to reserve your Coderwall team"
    mail to: @user.email, subject: @subject
  end

  def remind_to_invite_team_members(username)
    track_campaign('remind_to_invite_team_members')
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.touch(:remind_to_invite_team_members)

    @subject = "Is the #{@user.team.name} team all here?"
    mail to: @user.email, subject: @subject
  end

  def remind_to_create_protip(username)
    raise "NOT IMPLEMENTED"

    track_campaign('remind_to_create_protip')
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.touch(:remind_to_create_protip)

  end

  def remind_to_create_skills(username)
    raise "NOT IMPLEMENTED"

    track_campaign('remind_to_create_skills')
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.touch(:remind_to_create_skills)

  end

  def remind_to_link_accounts(username)
    raise "NOT IMPLEMENTED"

    track_campaign('remind_to_link_accounts')
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @user.touch(:remind_to_link_accounts)

  end

  def newsletter_june_18(username)
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    track_campaign("newsletter_delicious_coderwall")

    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    mail to: @user.email, subject: "Coderwall just got delicious"
  end

  def newsletter_networks(username)
    headers['X-Mailgun-Variables'] = {email_type: NEWSLETTER_EVENT}.to_json
    track_campaign("newsletter_networks")

    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    mail to: @user.email, subject: "Introducing Networks"
  end


  def new_applicant(user_id, job_id)
    headers['X-Mailgun-Variables'] = {email_type: NEW_APPLICANT_EVENT}.to_json
    #track_campaign("new_applicant")

    @user = User.find(user_id)
    @job = Opportunity.select([:id, :team_id, :name]).find(job_id)
    emails = @job.team.admin_accounts.pluck(:email)

    mail to: emails, bcc: admin_emails, subject: "New applicant for #{@job.title} from Coderwall"
  end

  def invoice(team_id, time, invoice_id=nil)
    headers['X-Mailgun-Variables'] = {email_type: INVOICE_EVENT}.to_json
    #track_campaign("new_applicant")
    @team = Team.find(team_id)
    team_admin_emails = @team.admin_accounts.pluck :email
    @invoice = invoice_id.nil? ? @team.account.invoice_for(Time.at(time)) : Stripe::Invoice.retrieve(invoice_id).to_hash.with_indifferent_access
    @customer = @team.account.customer

    mail to: team_admin_emails, bcc: admin_emails, subject: "Invoice for Coderwall enhanced team profile subscription"
  end


  def alert_admin(type, url = nil, message = nil)
    @type = type
    @url = url
    @message = message
    mail to: admin_emails, subject: "Coderwall Alert[#{type}]"
  end

  def template_example(username)
    @user = User.find_by_username(username)
    mail to: @user.email, subject: "This is a sample of all the template styles"
  end if Rails.env.development?

  def next_badge_to_send(user)
    next_badge_id = (user.achievements_unlocked_since_last_visit.map(&:id) - SentMail.where(user_id: user.id, mailable_type: Badge.name).map(&:mailable_id)).first
    Badge.where(id: next_badge_id).first
  end

  private
  def track_campaign(id)
    headers['X-Mailgun-Campaign-Id'] = id
  end

  def activity_message_for_user(user)
    raise "Failed notifying user because there was no new activity for #{user.username}" if !user.activity_since_last_visit?

    message = []
    subject = []

    if user.achievements_unlocked_since_last_visit.count > 0
      subject << "unlocked new achievements"
      message << ["unlocked #{pluralize(user.achievements_unlocked_since_last_visit.count, 'achievement')}"]
    end

    if user.endorsements_unlocked_since_last_visit.count > 0
      subject << "received endorsements"
      message << ["received #{pluralize(user.endorsements_unlocked_since_last_visit.count, 'endorsement')}"]
    end

    [subject.join(' and '), message.join(' and ')]
  end

  def new_badge_message_for_user(user, badge)
    ["unlocked new achievement", badge_for_message(badge)]
  end

  def badge_for_message(badge)
    skill_name = badge.tokenized_skill_name
    skill_name.blank? ? badge.for : "your #{skill_name} hacking skills and contribution."
  end

  def admin_emails
    User.admins.pluck(:email)
  end
end
