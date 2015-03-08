class ApplicationMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActiveSupport::Benchmarkable

  default_url_options[:host] = APP_DOMAIN
  default_url_options[:only_path] = false
  default from: '"Coderwall" <support@coderwall.com>'
  ACTIVITY_SUBJECT_PREFIX = '[Coderwall]'
end
