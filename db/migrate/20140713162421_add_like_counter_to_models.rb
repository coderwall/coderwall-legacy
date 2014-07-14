class AddLikeCounterToModels < ActiveRecord::Migration
  def change
    add_column :comments, :likes_count, :integer, default: 0
    add_column :protips, :likes_count, :integer, default: 0

    Comment.pluck(:id) do |id|
      Comment.reset_counters(id, :likes)
    end

    Protip.pluck(:id) do |id|
      Protip.reset_counters(id, :likes)
    end
  end
end
