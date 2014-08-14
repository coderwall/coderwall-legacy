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

every(1.day, 'cleanup:protips:associate_zombie_upvotes', at: '00:00') {}
every(1.day, 'clear_expired_sessions', at: '00:00') {}
every(1.day, 'facts:system', at: '00:00') {}
every(1.day, 'protips:recalculate_scores', at: '00:00') {}
every(1.day, 'search:sync', at: '00:00') {}
every(1.day, 'teams:refresh', at: '00:00') {}
