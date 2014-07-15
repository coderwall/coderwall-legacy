class CreateCaseInsensitiveIndexesOnUser < ActiveRecord::Migration
  # User.with_username looks up on following fields almost
  # constantly but with a UPPER(fieldname) = UPPER(val)
  # which is nasty and slow, add upcase and downcase indexes
  # to avoid the problem

  def up
    execute 'create index ix_users_github_lower on users (lower(github) varchar_pattern_ops)'
    execute 'create index ix_users_github_upper on users (upper(github) varchar_pattern_ops)'
    execute 'create index ix_users_linkedin_lower on users (lower(linkedin) varchar_pattern_ops)'
    execute 'create index ix_users_linkedin_upper on users (upper(linkedin) varchar_pattern_ops)'
    execute 'create index ix_users_twitter_lower on users (lower(twitter) varchar_pattern_ops)'
    execute 'create index ix_users_twitter_upper on users (upper(twitter) varchar_pattern_ops)'
    execute 'create index ix_users_username_lower on users (lower(username) varchar_pattern_ops)'
    execute 'create index ix_users_username_upper on users (upper(username) varchar_pattern_ops)'
  end

  def down
    execute 'drop index if exists ix_users_github_lower'
    execute 'drop index if exists ix_users_github_upper'
    execute 'drop index if exists ix_users_linkedin_lower'
    execute 'drop index if exists ix_users_linkedin_upper'
    execute 'drop index if exists ix_users_twitter_lower'
    execute 'drop index if exists ix_users_twitter_upper'
    execute 'drop index if exists ix_users_username_lower'
    execute 'drop index if exists ix_users_username_upper'
  end
end
