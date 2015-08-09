class AddTitleToMembership < ActiveRecord::Migration
  def change
    add_column :teams_members, :title, :string
    Teams::Member.includes(:user).find_each(batch_size: 200) do |membership|
      membership.update_attribute(:title, membership.user.title)
    end
  end
end
