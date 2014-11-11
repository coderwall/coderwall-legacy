require 'vcr_helper'

RSpec.describe Account, :type => :model do
  let(:team) { Fabricate(:team, account: nil) }
  let(:account) { { stripe_card_token: new_token } }

  let(:admin) {
    user = Fabricate(:user, team_id: team.id.to_s)
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
    Fabricate(:opportunity, team_id: team.id)
  end

  describe 'account creation' do

    it 'should create a valid account locally and on stripe' do
      # TODO: Refactor api calls to Sidekiq job
      VCR.use_cassette("Account") do

        expect(team.account).to be_nil
        team.build_account(account)
        team.account.admin_id = admin.id
        team.account.save_with_payment
        team.reload
        expect(team.account.stripe_card_token).to eq(account[:stripe_card_token])
        expect(team.account.stripe_customer_token).not_to be_nil
        expect(team.account.plan_ids).to eq([])

      end
    end

    it 'should still create an account if account admin not team admin' do
      # TODO: Refactor api calls to Sidekiq job
      VCR.use_cassette("Account") do

        team.build_account(account)
        some_random_user = Fabricate(:user)
        team.account.admin_id = some_random_user.id
        team.account.save_with_payment
        team.reload
        expect(team.account).not_to be_nil

      end
    end

    # FIXME: This request does not produce the same results out of two calls, under the Account cassette.
    # 	Something is stomping its request.
    # 	1st call, under record all will pass this test
    # 	2nd call, under new or none will fail, returning a previously recorded request
    it 'should not create an account if stripe_card_token invalid' do
      # TODO: Refactor api calls to Sidekiq job
      VCR.use_cassette("Account_Invalid") do

        account[:stripe_card_token] = "invalid"
        team.build_account(account)
        team.account.admin_id = admin.id
        team.account.save_with_payment
        team.reload
        expect(team.account).to be_nil

      end
    end

    it 'should not allow stripe_customer_token or admin to be set/updated' do
      # TODO: Refactor api calls to Sidekiq job
      VCR.use_cassette("Account") do

        some_random_user = Fabricate(:user)
        account[:stripe_customer_token] = "invalid_customer_token"
        account[:admin_id] = some_random_user.id
        team.build_account(account)
        team.account.save_with_payment
        team.reload
        expect(team.account).to be_nil

      end
    end
  end

  describe 'subscriptions' do
    let(:free_plan) { Plan.create!(amount: 0, interval: Plan::MONTHLY, name: "Starter") }
    let(:monthly_plan) { Plan.create!(amount: 15000, interval: Plan::MONTHLY, name: "Recruiting Magnet") }
    let(:onetime_plan) { Plan.create!(amount: 30000, interval: nil, name: "Single Job Post") }

    describe 'free subscription' do
      before(:each) do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.account).to be_nil
          team.build_account(account)
          team.account.admin_id = admin.id
          team.account.save_with_payment
          team.account.subscribe_to!(free_plan)
          team.reload

        end
      end

      it 'should add a free subscription' do
        expect(team.account.plan_ids).to include(free_plan.id)
        expect(team.paid_job_posts).to eq(0)
      end

      it 'should not allow any job posts' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.can_post_job?).to eq(false)
          expect(team.premium?).to eq(false)
          expect(team.valid_jobs?).to eq(false)
          expect { Fabricate(:opportunity, team_id: team.id) }.to raise_error(ActiveRecord::RecordNotSaved)

        end
      end

      # FIXME: This request does not produce the same results out of two calls.
      # 	1st call, under record all will pass this test
      # 	2nd call, under non will fail to match with previously recorded request
      # 	3rd call, under new will record a worket set of data for this test
      it 'should allow upgrade to monthly subscription' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          team.account.save_with_payment(monthly_plan)
          team.reload
          expect(team.can_post_job?).to eq(true)
          expect(team.paid_job_posts).to eq(0)
          expect(team.valid_jobs?).to eq(true)
          expect(team.has_monthly_subscription?).to eq(true)
          expect(team.premium?).to eq(true)

        end
      end

      it 'should allow upgrade to one-time job post charge' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          team.account.update_attributes({stripe_card_token: new_token})
          team.account.save_with_payment(onetime_plan)
          team.reload
          expect(team.can_post_job?).to eq(true)
          expect(team.valid_jobs?).to eq(true)
          expect(team.paid_job_posts).to eq(1)
          expect(team.premium?).to eq(true)

        end
      end
    end

    describe 'monthly paid subscription' do
      before(:each) do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.account).to be_nil
          team.build_account(account)
          team.account.admin_id = admin.id
          team.account.save_with_payment
          team.account.subscribe_to!(monthly_plan)
          team.reload

        end
      end

      it 'should add a paid monthly subscription' do
        expect(team.account.plan_ids).to include(monthly_plan.id)
        expect(team.paid_job_posts).to eq(0)
        expect(team.valid_jobs?).to eq(true)
        expect(team.can_post_job?).to eq(true)
        expect(team.premium?).to eq(true)
      end

      it 'should allow unlimited job posts' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.can_post_job?).to eq(true)
          5.times do
            Fabricate(:opportunity, team_id: team.id)
          end
          expect(team.can_post_job?).to eq(true)

        end
      end
    end

    describe 'one-time job post charge' do
      before(:each) do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.account).to be_nil
          team.build_account(account)
          team.account.admin_id = admin.id
          team.account.save_with_payment(onetime_plan)
          team.reload

        end
      end
      it 'should add a one-time job post charge' do
        expect(team.account.plan_ids).to include(onetime_plan.id)
        expect(team.paid_job_posts).to eq(1)
        expect(team.valid_jobs?).to eq(true)
        expect(team.can_post_job?).to eq(true)
        expect(team.premium?).to eq(true)
      end

      it 'should allow only one job-post' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          expect(team.can_post_job?).to eq(true)
          Fabricate(:opportunity, team_id: team.id)
          team.reload
          expect(team.paid_job_posts).to eq(0)
          expect(team.can_post_job?).to eq(false)
          expect { Fabricate(:opportunity, team_id: team.id) }.to raise_error(ActiveRecord::RecordNotSaved)

        end
      end

      it 'should allow upgrade to monthly subscription' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          team.account.update_attributes({stripe_card_token: new_token})
          team.account.save_with_payment(monthly_plan)
          team.reload
          expect(team.can_post_job?).to eq(true)
          expect(team.valid_jobs?).to eq(true)
          expect(team.paid_job_posts).to eq(1)
          expect(team.has_monthly_subscription?).to eq(true)
          5.times do
            Fabricate(:opportunity, team_id: team.id)
          end
          expect(team.can_post_job?).to eq(true)
          expect(team.paid_job_posts).to eq(1)
          expect(team.premium?).to eq(true)

        end
      end

      it 'should allow additional one time job post charges' do
        # TODO: Refactor api calls to Sidekiq job
        VCR.use_cassette("Account") do

          team.account.update_attributes({stripe_card_token: new_token})
          team.account.save_with_payment(onetime_plan)
          team.reload
          expect(team.paid_job_posts).to eq(2)
          expect(team.can_post_job?).to eq(true)
          2.times do
            Fabricate(:opportunity, team_id: team.id)
          end
          team.reload
          expect(team.paid_job_posts).to eq(0)
          expect(team.has_monthly_subscription?).to eq(false)
          expect(team.premium?).to eq(true)
          expect(team.valid_jobs?).to eq(true)

        end
      end
    end
  end
end
