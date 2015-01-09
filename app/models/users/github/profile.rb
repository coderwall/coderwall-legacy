# == Schema Information
#
# Table name: users_github_profiles
#
#  id                :integer          not null, primary key
#  login             :citext           not null
#  name              :string(255)
#  company           :string(255)
#  location          :string(255)
#  github_id         :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  hireable          :boolean          default(FALSE)
#  followers_count   :integer          default(0)
#  following_count   :integer          default(0)
#  github_created_at :datetime
#  github_updated_at :datetime
#  spider_updated_at :datetime
#

module Users
  module Github
    class Profile < ActiveRecord::Base
      belongs_to :user
      has_many :followers, class_name: 'Users::Github::Profiles::Follower' , foreign_key: :follower_id  , dependent: :delete_all
      has_many :repositories, :class_name => 'Users::Github::Repository' , foreign_key: :owner_id
      validates :login  , presence: true, uniqueness: true
      before_validation :copy_login_from_user,  on: :create
      after_create :extract_data_from_github


      private

      def copy_login_from_user
        self.login = user.github
      end

      def extract_data_from_github
        ExtractGithubProfile.perform_async(id)
      end

    end
  end
end
