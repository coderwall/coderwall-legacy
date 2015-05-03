class RenameCommentRemoteIpToUserIp < ActiveRecord::Migration
  def change
    rename_column :comments, :remote_ip, :user_ip
  end
end
