class AbuseMailer < ActionMailer::Base
  default_url_options[:host]      = 'coderwall.com'
  default_url_options[:only_path] = false

  ACTIVITY_SUBJECT_PREFIX = '[Coderwall]'

  default to: -> { User.admins.pluck(:email) },
    from: '"Coderwall" <support@coderwall.com>'

  def report_inappropriate(public_id, opts={})
    headers['X-Mailgun-Campaign-Id'] = 'coderwall-abuse-report_inappropriate'
    begin
    @protip = Protip.find_by_public_id!(public_id)
    @reporting_user = opts[:user_id]
    @ip_address = opts[:ip]

    mail subject: "Spam Report for Protip: \"#{@protip.title}\" (#{@protip.id})"
    rescue ActiveRecord::RecordNotFound
      #Protip was probably deleted
      true
    end
  end
end
