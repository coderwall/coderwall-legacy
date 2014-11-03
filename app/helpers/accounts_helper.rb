module AccountsHelper
  def monthly_plan_price(plan)
    plan.nil? ? Plan.enhanced_team_page_monthly.try(:price) : plan.price
  end

  def purchased_plan(plan)
    plan.nil? ? "Monthly" : plan.name
  end

  def card_for(customer)
    card = customer[:active_card] || customer[:cards].first
  end

  def invoice_date(invoice)
    Time.at(invoice[:date]).to_date.to_formatted_s(:long_ordinal)
  end

  def subscription_period_for(invoice, period)
    subscription_period = invoice[:lines][:data].first[:period][period]
    Time.at(subscription_period).to_date.to_formatted_s(:long_ordinal)
  end
end
