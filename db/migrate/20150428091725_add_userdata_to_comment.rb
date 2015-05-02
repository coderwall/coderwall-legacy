class AddUserdataToComment < ActiveRecord::Migration
  def change
    add_column :comments, :user_name, :string
    add_column :comments, :user_email, :string
    add_column :comments, :user_agent, :string
    add_column :comments, :remote_ip, :inet
    add_column :comments, :request_format, :string
  end
end
