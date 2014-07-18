class Users::Github::Organization < ActiveRecord::Base
 has_many :followers, class_name: 'Users::Github::Organizations::Follower', dependent: :delete_all
end
