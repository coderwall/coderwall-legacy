module AccountsHelper
  def monthly_plan_price(plan)
    plan.nil? ? Plan.enhanced_team_page_monthly.try(:price) : plan.price
  end

  def purchased_plan(plan)
    plan.nil? ? 'Monthly' : plan.name
  end
end
