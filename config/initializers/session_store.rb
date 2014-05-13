# Be sure to restart your server when you modify this file.

# Badgiy::Application.config.session_store :cookie_store, :key => '_coderwall_session'
# Badgiy::Application.config.session_store :cache_store, :key => '_coderwall_session'

# Badgiy::Application.config.session_store :cookie_store, :key => '_coderwall_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")

# require 'action_dispatch/middleware/session/dalli_store'
#
# ENV['MEMCACHE_SERVERS']  ||= '127.0.0.1'
#
# Rails.application.config.session_store = :dalli_store, ENV['MEMCACHE_SERVERS'], { :namespace => 'sessions', :key => '_cw',  :expires_in => 1.day, :compress => false}

Badgiy::Application.config.session_store :active_record_store, expire_after: 1.month, session_key: '_session', secret: ENV['SESSION_SECRET']
