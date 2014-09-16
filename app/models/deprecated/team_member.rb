# Postgresed  [WIP] : Teams::Member
module Deprecated
  class TeamMember
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :team

    field :user_id
    field :inviter_id
    field :email
    field :name
    field :username
    field :thumbnail_url
    field :badges_count

    validates_uniqueness_of :user_id

    def user
      @user ||= User.where(id: self[:user_id]).first
    end

    def score
      badges.all.sum(&:weight)
    end

    def display_name
      name || username
    end

    [:badges, :title, :endorsements].each do |m|
      define_method(m) { user.try(m) }
    end
  end
end
