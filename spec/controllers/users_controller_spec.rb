require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) do
    user = Fabricate.build(:user)
    user.badges << Fabricate.build(:badge, badge_class_name: 'Octopussy')
    user.save!
    user
  end

  let(:github_response) { JSON.parse(File.read('./spec/fixtures/oauth/github_response.json')).with_indifferent_access }

  it 'should get user page by ignoring the case' do
    get :show, username: user.username.downcase
    expect(response).to be_success
    get :show, username: user.username.upcase
    expect(response).to be_success
    expect(assigns(:user)).to eq(user)
  end

  it 'multiple json requests should have same etag' do
    get :show, username: user.username, format: :json
    first_etag = response.headers['ETag']
    get :show, username: user.username, format: :json
    second_etag = response.headers['ETag']
    expect(first_etag).to eq(second_etag)
  end

  it 'should have different etags for json and jsonp' do
    get :show, username: user.username, format: :json
    json_etag = response.headers['ETag']

    get :show, username: user.username, format: :json, callback: 'foo'
    jsonp_etag = response.headers['ETag']

    expect(jsonp_etag).not_to eq(json_etag)
  end

  it 'should save referral if first hit' do
    get :show, username: user.username
    expect(session[:referred_by]).to eq(user.referral_token)
  end

  it 'should not save referral if they have already been to site' do
    request.cookies[:trc] = 'asdfsdafsadfdsafadsfda'
    get :show, username: user.username
    expect(session[:referred_by]).to be_blank
  end

  describe 'tracking viral coefficient on signup' do
    it 'should add referred by if present in session to new user' do
      session[:referred_by] = 'asdfasdf'
      session['oauth.data'] = github_response
      post :create, user: { location: 'SF', username: 'testingReferredBy' }
      user = User.find_by_username('testingReferredBy')
      expect(user.referred_by).to eq('asdfasdf')
    end

    it 'should not add referred by if not present' do
      session['oauth.data'] = github_response
      post :create, user: { location: 'SF', username: 'testingReferredBy' }
      user = User.find_by_username('testingReferredBy')
      expect(user.referred_by).to be_nil
    end
  end

  it 'should tracking utm UTM_CAMPAIGN on signup' do
    session[:utm_campaign] = 'asdfasdf'
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF', username: 'testingUTM_campaign' }
    user = User.find_by_username('testingUTM_campaign')
    expect(user.utm_campaign).to eq('asdfasdf')
  end

  it 'should capture utm_campaign if ever in params' do
    get :show, username: user.username, utm_campaign: 'asdfasdf'
    expect(session[:utm_campaign]).to eq('asdfasdf')
  end

  it 'applies oauth information to user on creation' do
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF' }
    assigns[:user].github == 'throwaway1'
    assigns[:user].github_token == '59cdff603a4e70d47f0a28b5ccaa3935aaa790cf'
  end

  it 'extracts location from oauth' do
    github_response['extra']['raw_info']['location'] = 'San Francisco'
    session['oauth.data'] = github_response
    post :create, user: {}
    expect(assigns[:user].location).to eq('San Francisco')
  end

  it 'extracts blog if present from oauth' do
    github_response['info']['urls']['Blog'] = 'http://theagiledeveloper.com'
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF' }
    expect(assigns[:user].blog).to eq('http://theagiledeveloper.com')
  end

  it 'extracts joined date from oauth' do
    github_response['info']['urls']['Blog'] = 'http://theagiledeveloper.com'
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF' }
    expect(assigns[:user].joined_github_on).to eq(Date.parse('2012-01-06T20:49:02Z'))
  end

  describe 'linkedin' do
    let(:linkedin_response) { JSON.parse(File.read('./spec/fixtures/oauth/linkedin_response.json')).with_indifferent_access }

    it 'setups up new user and redirects to signup page' do
      session['oauth.data'] = linkedin_response
      post :create, user: {}

      expect(assigns[:user].username).to be_nil
      expect(assigns[:user].location).to be_nil
      expect(assigns[:user].linkedin).to be_nil
      expect(assigns[:user].linkedin_token).to eq('acafe540-606a-4f73-aef7-f6eba276603')
      expect(assigns[:user].linkedin_secret).to eq('df7427be-3d93-4563-baef-d1d38826686')
      expect(assigns[:user].linkedin_id).to eq('DlC5AmUPnM')
      expect(assigns[:user].linkedin_public_url).to eq('http://www.linkedin.com/in/matthewdeiters')
    end
  end

  describe 'twitter' do
    let(:twitter_response) { JSON.parse(File.read('./spec/fixtures/oauth/twitter_response.json')).with_indifferent_access }

    it 'setups up new user and redirects to signup page' do
      session['oauth.data'] = twitter_response
      post :create, user: {}

      expect(assigns[:user].username).to eq('mdeiters')
      expect(assigns[:user].twitter).to eq('mdeiters')
      expect(assigns[:user].twitter_token).to eq('6271932-8erxrXfJykBNMrvsdCEq5WqKd6FIcO97L9BzvPq7')
      expect(assigns[:user].twitter_secret).to eq('8fRS1ZARd6Wm53wvvDwHNrBmZcW0H2aSwmQjuOTHl')
      expect(assigns[:user].twitter_id).to eq('6271932')
      expect(assigns[:user].location).to eq('San Francisco')
      expect(assigns[:user].about).to eq('Dad. Amateur Foodie. Founder Extraordinaire of @coderwall')
    end
  end
end
