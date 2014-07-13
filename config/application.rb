require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sprockets/engines'

Bundler.require(:default, :assets, Rails.env) if defined?(Bundler)

module Badgiy
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app)

    config.autoload_paths += Dir[ Rails.root.join('app', 'models',      'concerns', '**/') ]
    config.autoload_paths += Dir[ Rails.root.join('app', 'controllers', 'concerns', '**/') ]
    config.autoload_paths += Dir[ Rails.root.join('app', 'services',    '**/'            ) ]
    config.autoload_paths += Dir[ Rails.root.join('app', 'jobs',    '**/'            ) ]

    config.autoload_paths << File.join(config.root, 'app', 'models', 'badges')
    config.autoload_paths << File.join(config.root, 'lib')

    config.i18n.enforce_available_locales = true

    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]


    config.ember.variant = Rails.env.downcase.to_sym
    config.assets.js_compressor  = :uglifier

    config.logger = Logger.new(STDOUT)
    config.logger.level = Logger.const_get(ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'INFO')

    config.after_initialize do
      if %w{development test}.include?(Rails.env)
        Hirb.enable
      end
    end

    config.rakismet.key = ENV['AKISMET_KEY']
    config.rakismet.url = ENV['AKISMET_URL']
  end
end

ENABLE_TRACKING = !ENV['MIXPANEL_TOKEN'].blank?

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  %(<span class="field_with_errors">#{html_tag}</span>).html_safe
}

#require 'font_assets/railtie' # => loads font middleware so cloudfront can serve fonts that render in Firefox
