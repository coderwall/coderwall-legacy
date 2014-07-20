class SetDefaultToPlanCurrency < ActiveRecord::Migration
  def up
    change_column :plans , :currency, :string, default: 'usd'
    change_column :plans , :interval, :string, default: 'month'
    add_column :plans, :interval_in_seconds, :integer, default: 1.month.to_i
  end
end
