module Coderwall
  module Banning
    class User

      class << self
        def ban(user)
          user.update_attribute(:banned_at, Time.now.utc)
        end

        def unban(user)
          user.update_attribute(:banned_at, nil)
        end
      end

    end
  end
end
