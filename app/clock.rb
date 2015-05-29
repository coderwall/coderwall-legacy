# IMPORTANT: Coderwall runs in the Pacific Timezone

require_relative '../config/boot'
require_relative '../config/environment'

include Clockwork

# On the first of every month send the popular protips from the previous month.
every(1.day, 'protip_mailer:popular_protips', if: ->(t){ t.day == 1 }) do
  if ENV['PROTIP_MAILER_POPULAR_PROTIPS']
    last_month = 1.month.ago
    ProtipMailerPopularProtipsWorker.perform_async(last_month.beginning_of_month, last_month.end_of_month)
  else
    Rails.logger.warn('PROTIP_MAILER_POPULAR_PROTIPS is disabled. Set `heroku config:set PROTIP_MAILER_POPULAR_PROTIPS=true` to allow sending scheduled emails.')
  end
end

every(1.day, 'award:refresh:stale', at: '00:00') do
  RefreshStaleUsersWorker.perform_async
end

# Runs as 1:00 AM Pacific
every(1.day, 'award:activate:active', at: '01:00') do
  ActivatePendingUsersWorker.perform_async
end

every(1.day, 'cleanup:protips:associate_zombie_upvotes', at: '02:00') do
  CleanupProtipsAssociateZombieUpvotesJob.perform_async
end

every(1.day, 'search:sync', at: '03:00') do
  SearchSyncJob.perform_async
end

every(1.day, 'protips:recalculate_scores', at: '04:00') do
  ProtipsRecalculateScoresJob.perform_async
end

every(1.day, 'sitemap:refresh', at: '06:00') do
  SitemapRefreshWorker.perform_async
end

# This is tied with broken code. Probably should delete
# every(1.day, 'facts:system', at: '00:00') {}
