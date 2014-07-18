class Users::Github::Repositories::Contributor < ActiveRecord::Base
  belongs_to :profile, class_name: 'Users::Github::Profile'
  belongs_to :repository, :class_name => 'Users::Github::Repository'
end
