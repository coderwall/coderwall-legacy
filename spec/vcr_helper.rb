require 'vcr'
require 'rails_helper.rb'

def record_mode
  case ENV['VCR_RECORD_MODE']
	when 'all'
   :all
  when 'new'
    :new_episodes
  when 'once'
    :once
  else
    :none
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost                        = true
  c.default_cassette_options                = { record: record_mode }
  c.allow_http_connections_when_no_cassette = false
  c.configure_rspec_metadata!

  # Github
  c.filter_sensitive_data('<GITHUB_ADMIN_USER_PASSWORD>') { ENV['GITHUB_ADMIN_USER_PASSWORD'] }
  c.filter_sensitive_data('<GITHUB_CLIENT_ID>')						{ ENV['GITHUB_CLIENT_ID'] }
  c.filter_sensitive_data('<GITHUB_SECRET>') 							{ ENV['GITHUB_SECRET'] }

  # LinkedIn
  c.filter_sensitive_data('<LINKEDIN_KEY>') 							{ ENV['LINKEDIN_KEY'] }
  c.filter_sensitive_data('<LINKEDIN_SECRET>') 						{ ENV['LINKEDIN_SECRET'] }

  # Mailgun
  c.filter_sensitive_data('<MAILGUN_API_KEY>') 						{ ENV['MAILGUN_API_KEY'] }
  c.filter_sensitive_data('<MAILGUN_TOKEN>') 							{ ENV['MAILGUN_TOKEN'] }

  # Mixpanel
  c.filter_sensitive_data('<MIXPANEL_API_SECRET>') 				{ ENV['MIXPANEL_API_SECRET'] }
  c.filter_sensitive_data('<MIXPANEL_TOKEN>') 						{ ENV['MIXPANEL_TOKEN'] }

  # Twitter
  c.filter_sensitive_data('<TWITTER_ACCOUNT_ID>') 				{ ENV['TWITTER_ACCOUNT_ID'] }
  c.filter_sensitive_data('<TWITTER_CONSUMER_KEY>') 			{ ENV['TWITTER_CONSUMER_KEY'] }
  c.filter_sensitive_data('<TWITTER_CONSUMER_SECRET>') 		{ ENV['TWITTER_CONSUMER_SECRET'] }
  c.filter_sensitive_data('<TWITTER_OAUTH_SECRET>') 			{ ENV['TWITTER_OAUTH_SECRET'] }
  c.filter_sensitive_data('<TWITTER_OAUTH_TOKEN>') 				{ ENV['TWITTER_OAUTH_TOKEN'] }

  # Stripe
  c.filter_sensitive_data('<STRIPE_PUBLISHABLE_KEY>') 		{ ENV['STRIPE_PUBLISHABLE_KEY'] }
  c.filter_sensitive_data('<STRIPE_SECRET_KEY>') 					{ ENV['STRIPE_SECRET_KEY'] }

  # Akismet
  c.filter_sensitive_data('<AKISMET_KEY>') 								{ ENV['AKISMET_KEY'] }
end
