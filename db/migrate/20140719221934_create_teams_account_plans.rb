class CreateTeamsAccountPlans < ActiveRecord::Migration
  def change
    create_table :teams_account_plans, id: false do |t|
        t.integer :plan_id
        t.integer :account_id
    end
    #TODO index in rails 4
  end
end
