class Abuse < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActiveSupport::Benchmarkable

  default_url_options[:host]      = 'coderwall.com'
  default_url_options[:only_path] = false

  default to: Proc.new { User.admins.map(&:email) },
    from: '"Coderwall" <support@coderwall.com>'

  def report_inappropriate(opts)
    headers['X-Mailgun-Campaign-Id'] = 'coderwall-abuse-report_inappropriate'

    @ip_address = opts[:ip_address]
    @reporting_user = opts[:reporting_user]
    protip_public_id = (opts[:protip_public_id] || opts['protip_public_id'])
    @protip = Protip.find_by_public_id(protip_public_id)

    mail subject: "Spam Report for Protip: \"#{@protip.title}\" (#{@protip.id})"
  end
end
