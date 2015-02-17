class AbuseMailer < ApplicationMailer

  def report_inappropriate(public_id, opts={})
    begin
      headers['X-Mailgun-Campaign-Id'] = 'coderwall-abuse-report_inappropriate'
      @protip = Protip.find_by_public_id!(public_id)
      @reporting_user = opts[:user_id]
      @ip_address = opts[:ip]

      mail to: User.admins.pluck(:email), subject: "Spam Report for Protip: \"#{@protip.title}\" (#{@protip.id})"
    rescue ActiveRecord::RecordNotFound
      #Protip was probably deleted
      true
    end
  end
end
