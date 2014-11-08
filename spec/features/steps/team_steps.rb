step 'a team :team_name exists' do |team_name|
  Fabricate(:team, name: team_name)
end

step 'team :team_name is subscribed to plan :plan_name with card :card_no' do |team_name, plan_name, card_no|
  plan = Fabricate.build(:plan, name: plan_name)

  stripe_plan = JSON.parse(File.read('./spec/fixtures/stripe/stripe_plan.json')).with_indifferent_access.tap do |h|
    h[:interval] = plan.interval
    h[:name] = plan.name
    h[:created] = plan.created_at
    h[:amount] = plan.amount
    h[:currency] = plan.currency
    h[:id] = plan.public_id
  end
  stub_request(:post, /api.stripe.com\/v1\/plans/).to_return(body: stripe_plan.to_json)

  plan.save

  team = Team.where(name: team_name).first
  team.account.plan_ids = [plan.id]
  team.save

  stripe_customer = JSON.parse(File.read('./spec/fixtures/stripe/stripe_customer.json')).with_indifferent_access.tap do |h|
    h[:id] = team.account.stripe_customer_token
    h[:description] = "test@test.com for #{team_name}"
    h[:cards][:data].first[:last4] = card_no
  end
  stub_request(:get, /api.stripe.com\/v1\/customers\/#{team.account.stripe_customer_token}/).to_return(body: stripe_customer.to_json)
end

step 'team :team_name has invoices with data:' do |team_name, table|
  team = Team.where(name: team_name).first
  data = table.rows_hash

  stripe_invoices = JSON.parse(File.read('./spec/fixtures/stripe/stripe_invoices.json')).with_indifferent_access.tap do |h|
    h[:data].first[:date] = Date.parse(data['Date']).to_time.to_i
    h[:data].first[:lines][:data].first[:period][:start] = Date.parse(data['Start']).to_time.to_i
    h[:data].first[:lines][:data].first[:period][:end] = Date.parse(data['End']).to_time.to_i
  end
  stub_request(:get, /api.stripe.com\/v1\/invoices/).to_return(body: stripe_invoices.to_json)
end

step 'I am member of team :team_name' do |team_name|
  team = Team.find_by(name: team_name)
  team.add_user(@logged_in_user)
  team.account.admin_id = @logged_in_user.id
  team.save
end
