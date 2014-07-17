class SetDefaultToUserLastRequest < ActiveRecord::Migration
  def up
    change_column :users, :last_request_at, :datetime, default: 'NOW'
  end
end
