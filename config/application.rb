require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
I18n.config.enforce_available_locales = false

Bundler.require(*Rails.groups)

module Coderwall
  class Application < Rails::Application

    config.autoload_paths += Dir[Rails.root.join('app', 'models',      'badges'          )]
    config.autoload_paths += Dir[Rails.root.join('lib', '**/'                            )]

    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.encoding = 'utf-8'

    config.assets.js_compressor = :uglifier

    config.after_initialize do
      if ENV['ENABLE_HIRB'] && %w{development test}.include?(Rails.env)
        Hirb.enable
      end
    end

    config.exceptions_app = self.routes
    config.active_record.raise_in_transactional_callbacks = true
  end
end

ENABLE_TRACKING = !ENV['MIXPANEL_TOKEN'].blank?

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  %(<span class="field_with_errors">#{html_tag}</span>).html_safe
}
