class DropProccessingQueue < ActiveRecord::Migration
  def up
    drop_table :processing_queues
  end
end
