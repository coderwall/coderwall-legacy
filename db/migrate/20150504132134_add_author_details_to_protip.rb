class AddAuthorDetailsToProtip < ActiveRecord::Migration
  def change
    add_column :protips, :user_name, :string
    add_column :protips, :user_email, :string
    add_column :protips, :user_agent, :string
    add_column :protips, :user_ip, :inet
  end
end
