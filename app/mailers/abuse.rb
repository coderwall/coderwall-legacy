class Abuse < ActionMailer::Base
  include Resque::Mailer if Rails.env.production?
  include ActionView::Helpers::TextHelper
  include ActiveSupport::Benchmarkable

  default_url_options[:host]      = 'coderwall.com'
  default_url_options[:only_path] = false

  default to: proc { User.admins.map(&:email) },
          from: '"Coderwall" <support@coderwall.com>'

  def report_inappropriate(opts)
    headers['X-Mailgun-Campaign-Id'] = 'coderwall-abuse-report_inappropriate'

    @ip_address = opts[:ip_address]
    @reporting_user = opts[:reporting_user]
    protip_public_id = (opts[:protip_public_id] || opts['protip_public_id'])
    @protip = Protip.find_by_public_id(protip_public_id)

    mail subject: "Spam Report for Protip: \"#{@protip.title}\" (#{@protip.id})"
  end

  if Rails.env.development?
    class Preview < MailView
      def report_inappropriate
        user = User.active.order('Random()').first
        protip = Protip.last
        mail = ::Abuse.report_inappropriate(reporting_user: user, ip_address: '127.0.0.1', protip: protip)
        mail
      end
    end
  end
end
