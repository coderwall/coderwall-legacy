class AddSpamReportToProtipAndComment < ActiveRecord::Migration
  def change
    add_column :comments, :spam_reports_count, :integer, default: 0
    add_column :comments, :state, :string, default: 'active'

    add_column :protips, :spam_reports_count, :integer, default: 0
    add_column :protips, :state, :string, default: 'active'
  end
end
