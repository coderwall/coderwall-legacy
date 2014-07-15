RSpec.describe AccountsController, type: :controller do
  let(:team) { Fabricate(:team) }
  let(:plan) { Plan.create(amount: 20_000, interval: Plan::MONTHLY, name: 'Monthly') }
  let(:current_user) { Fabricate(:user) }

  before do
    team.add_user(current_user)
    controller.send :sign_in, current_user
  end

  def new_token
    Stripe::Token.create(card: { number: 4_242_424_242_424_242, cvc: 224, exp_month: 12, exp_year: 14 }).try(:id)
  end

  def valid_params
    {
      chosen_plan: plan.public_id,
      stripe_card_token: new_token
    }
  end

  it 'should create an account and send email' do
    post :create,  team_id: team.id, account: valid_params
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.first.body.encoded).to include(team.name)
    expect(ActionMailer::Base.deliveries.first.body.encoded).to include(plan.name)
  end
end
