module TeamMigration
  extend ActiveSupport::Concern

  included do
    scope :zombies, -> { where(state: 'zombie') }
  end

  module ClassMethods

    def the_walking_deads
      active_teams_ids = Teams::Member.pluck(:team_id).uniq
      where('id not in (?)', active_teams_ids)
    end

    def mark_the_walking_deads!
      the_walking_deads.update_all(state: 'zombie')
    end

    def kill_zombies!
      zombies.destroy_all
    end

  end
end
