class CreateSpamReports < ActiveRecord::Migration
  def change
    create_table "spam_reports", force: true do |t|
      t.integer  "spammable_id",   null: false
      t.string   "spammable_type", null: false
      t.timestamps
    end
  end
end
