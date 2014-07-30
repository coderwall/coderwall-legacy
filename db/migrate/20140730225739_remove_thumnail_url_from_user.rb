class RemoveThumnailUrlFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :thumbnail_url
  end

end
