# IMPORTANT: Coderwall runs in the Pacific Timezone

require_relative '../config/boot'
require_relative '../config/environment'

include Clockwork


# Runs as 1:01 AM Pacific
every(1.day, 'award:activate:active', at: '01:01') do
  ActivatePendingUsersWorker.perform_async
end

every(1.day, 'award:refresh:stale', at: '00:00') do
  RefreshStaleUsersWorker.perform_async
end

# On the first of every month send the popular protips from the previous month.
every(1.day, 'protip_mailer:popular_protips', if: ->(t){ t.day == 1 }) do
  last_month = 1.month.ago
  ProtipMailerPopularProtipsWorker.perform_async(last_month.beginning_of_month, last_month.end_of_month)
end

every(1.day, 'cleanup:protips:associate_zombie_upvotes', at: '00:00') {}
every(1.day, 'clear_expired_sessions', at: '00:00') {}
every(1.day, 'facts:system', at: '00:00') {}
every(1.day, 'protips:recalculate_scores', at: '00:00') {}
every(1.day, 'search:sync', at: '00:00') {}
every(1.day, 'teams:refresh', at: '00:00') {}
