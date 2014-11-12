RSpec.describe AccountsController, :type => :controller do
  let(:team) { Fabricate(:team, account: nil) }
  let(:plan) { Plan.create(amount: 20000, interval: Plan::MONTHLY, name: 'Monthly') }
  let(:current_user) { Fabricate(:user) }

  before do
    team.add_member(current_user)
    controller.send :sign_in, current_user
  end

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
    # TODO: Refactor API call to Sidekiq Job
    VCR.use_cassette('AccountsController') do

      post :create, { team_id: team.id, account: valid_params }
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.first.body.encoded).to include(team.name)
      expect(ActionMailer::Base.deliveries.first.body.encoded).to include(plan.name)

    end
  end

  describe '#send_inovice' do
    before do
      team.account = Account.new

      allow(Team).to receive(:find) { team }
      allow(team.account).to receive(:send_invoice_for) { true }
      allow(team.account).to receive(:admin) { current_user }

      allow(Time).to receive(:current) { Date.parse('02/11/15').to_time } # so we do not bother with the time portion of the day
    end

    it 'calls send_invoice for the last month' do
      expect(team.account).to receive(:send_invoice_for).with(Date.parse('02/10/15').to_time)
      get :send_invoice, id: '123'
    end

    it 'displays success message' do
      get :send_invoice, id: '123'
      expect(flash[:notice]).to eq("sent invoice for October to #{current_user.email}")
    end

    it 'redirects to team profile' do
      get :send_invoice, id: '123'
      expect(response).to redirect_to(teamname_path(slug: team.slug))
    end

    it 'displays failure message' do
      allow(team.account).to receive(:send_invoice_for) { false }
      get :send_invoice, id: '123'
      expect(flash[:error]).to eq('There was an error in sending an invoice')
    end

  end
end
