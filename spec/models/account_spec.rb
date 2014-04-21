describe Account do
  let(:team) { Fabricate(:team) }
  let(:account) { { stripe_card_token: new_token } }

  let(:admin) {
    user = Fabricate(:user, team_document_id: team.id.to_s)
    team.admins << user.id
    team.save
    user
  }

  before(:all) do
    url = 'http://maps.googleapis.com/maps/api/geocode/json?address=San+Francisco%2C+CA&language=en&sensor=false'
    @body ||= File.read(File.join(Rails.root, 'spec', 'fixtures', 'google_maps.json'))
    stub_request(:get, url).to_return(body: @body)
  end

  def new_token
    Stripe::Token.create(card: { number: 4242424242424242, cvc: 224, exp_month: 12, exp_year: 14 }).try(:id)
  end

  def post_job_for(team)
    Fabricate(:opportunity, team_document_id: team.id)
  end

  describe 'account creation' do

    it 'should create a valid account locally and on stripe' do
      team.account.should be_nil
      team.build_account(account)
      team.account.admin_id = admin.id
      team.account.save_with_payment
      team.reload
      team.account.stripe_card_token.should == account[:stripe_card_token]
      team.account.stripe_customer_token.should_not be_nil
      team.account.plan_ids.should == []
    end

    it 'should still create an account if account admin not team admin' do
      team.build_account(account)
      some_random_user = Fabricate(:user)
      team.account.admin_id = some_random_user.id
      team.account.save_with_payment
      team.reload
      team.account.should_not be_nil
    end

    it 'should not create an account if stripe_card_token invalid' do
      account[:stripe_card_token] = "invalid"
      team.build_account(account)
      team.account.admin_id = admin.id
      team.account.save_with_payment
      team.reload
      team.account.should be_nil
    end

    it 'should not allow stripe_customer_token or admin to be set/updated' do
      some_random_user = Fabricate(:user)
      account[:stripe_customer_token] = "invalid_customer_token"
      account[:admin_id] = some_random_user.id
      team.build_account(account)
      team.account.save_with_payment
      team.reload
      team.account.should be_nil
    end
  end

  describe 'subscriptions' do
    let(:free_plan) { Plan.create!(amount: 0, interval: Plan::MONTHLY, name: "Starter") }
    let(:monthly_plan) { Plan.create!(amount: 15000, interval: Plan::MONTHLY, name: "Recruiting Magnet") }
    let(:onetime_plan) { Plan.create!(amount: 30000, interval: nil, name: "Single Job Post") }

    describe 'free subscription' do
      before(:each) do
        team.account.should be_nil
        team.build_account(account)
        team.account.admin_id = admin.id
        team.account.save_with_payment
        team.account.subscribe_to!(free_plan)
        team.reload
      end

      it 'should add a free subscription' do
        team.account.plan_ids.should include(free_plan.id)
        team.paid_job_posts.should == 0
      end

      it 'should not allow any job posts' do
        team.can_post_job?.should == false
        team.premium?.should == false
        team.valid_jobs?.should == false
        lambda { Fabricate(:opportunity, team_document_id: team.id) }.should raise_error(ActiveRecord::RecordNotSaved)
      end

      it 'should allow upgrade to monthly subscription' do
        team.account.save_with_payment(monthly_plan)
        team.reload
        team.can_post_job?.should == true
        team.paid_job_posts.should == 0
        team.valid_jobs?.should == true
        team.has_monthly_subscription?.should == true
        team.premium?.should == true
      end

      it 'should allow upgrade to one-time job post charge' do
        team.account.update_attributes({stripe_card_token: new_token})
        team.account.save_with_payment(onetime_plan)
        team.reload
        team.can_post_job?.should == true
        team.valid_jobs?.should == true
        team.paid_job_posts.should == 1
        team.premium?.should == true
      end
    end

    describe 'monthly paid subscription' do
      before(:each) do
        team.account.should be_nil
        team.build_account(account)
        team.account.admin_id = admin.id
        team.account.save_with_payment
        team.account.subscribe_to!(monthly_plan)
        team.reload
      end

      it 'should add a paid monthly subscription' do
        team.account.plan_ids.should include(monthly_plan.id)
        team.paid_job_posts.should == 0
        team.valid_jobs?.should == true
        team.can_post_job?.should == true
        team.premium?.should == true
      end

      it 'should allow unlimited job posts' do
        team.can_post_job?.should == true
        5.times do
          Fabricate(:opportunity, team_document_id: team.id)
        end
        team.can_post_job?.should == true
      end
    end

    describe 'one-time job post charge' do
      before(:each) do
        team.account.should be_nil
        team.build_account(account)
        team.account.admin_id = admin.id
        team.account.save_with_payment(onetime_plan)
        team.reload
      end
      it 'should add a one-time job post charge' do
        team.account.plan_ids.should include(onetime_plan.id)
        team.paid_job_posts.should == 1
        team.valid_jobs?.should == true
        team.can_post_job?.should == true
        team.premium?.should == true
      end

      it 'should allow only one job-post' do
        team.can_post_job?.should == true
        Fabricate(:opportunity, team_document_id: team.id)
        team.reload
        team.paid_job_posts.should == 0
        team.can_post_job?.should == false
        lambda { Fabricate(:opportunity, team_document_id: team.id) }.should raise_error(ActiveRecord::RecordNotSaved)
      end

      it 'should allow upgrade to monthly subscription' do
        team.account.update_attributes({stripe_card_token: new_token})
        team.account.save_with_payment(monthly_plan)
        team.reload
        team.can_post_job?.should == true
        team.valid_jobs?.should == true
        team.paid_job_posts.should == 1
        team.has_monthly_subscription?.should == true
        5.times do
          Fabricate(:opportunity, team_document_id: team.id)
        end
        team.can_post_job?.should == true
        team.paid_job_posts.should == 1
        team.premium?.should == true
      end

      it 'should allow additional one time job post charges' do
        team.account.update_attributes({stripe_card_token: new_token})
        team.account.save_with_payment(onetime_plan)
        team.reload
        team.paid_job_posts.should == 2
        team.can_post_job?.should == true
        2.times do
          Fabricate(:opportunity, team_document_id: team.id)
        end
        team.reload
        team.paid_job_posts.should == 0
        team.has_monthly_subscription?.should == false
        team.premium?.should == true
        team.valid_jobs?.should == true
      end
    end
  end
end
