class Campaigns < ActionMailer::Base
  include Resque::Mailer if Rails.env.production?
  include ActionView::Helpers::TextHelper
  add_template_helper(ApplicationHelper)

  def self.queue
    :digest_mailer
  end

  default_url_options[:host] = "coderwall.com"
  default_url_options[:only_path] = false
  default from: '"Coderwall" <support@coderwall.com>'

  def asm_badge(username)
    headers['X-Mailgun-Campaign-Id'] = 'asm-badge-2013-12-04'

    @user = User.with_username(username)

    mail to: @user.email, subject: "[Coderwall] Unlock the new Entrepreneur badge"
  end

  if Rails.env.development?
    class Preview < MailView

      def asm_badge
        user = User.active.order("Random()").first
        mail = ::Campaigns.asm_badge(user.username)
        mail
      end

    end
  end

end