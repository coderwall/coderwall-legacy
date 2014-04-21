describe AccountsController do
  let(:team) { Fabricate(:team) }
  let(:plan) { Plan.create(amount: 20000, interval: Plan::MONTHLY, name: 'Monthly') }
  let(:current_user) { Fabricate(:user) }

  before {
    team.add_user(current_user)
    controller.send :sign_in, current_user
  }

  def new_token
    Stripe::Token.create(card: { number: 4242424242424242, cvc: 224, exp_month: 12, exp_year: 14 }).try(:id)
  end

  def valid_params
    {
      chosen_plan: plan.public_id,
      stripe_card_token: new_token
    }
  end

  it 'should create an account and send email' do
    post :create, { team_id: team.id, account: valid_params }
    ActionMailer::Base.deliveries.size.should == 1
    ActionMailer::Base.deliveries.first.body.encoded.should include(team.name)
    ActionMailer::Base.deliveries.first.body.encoded.should include(plan.name)
  end
end
