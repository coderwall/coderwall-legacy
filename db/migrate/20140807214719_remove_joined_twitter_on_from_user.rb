class RemoveJoinedTwitterOnFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :joined_twitter_on
  end

end
