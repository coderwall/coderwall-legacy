require 'spec_helper'

RSpec.describe UsersController, type: :controller, skip: true do
  let(:user) do
    user = Fabricate.build(:user)
    user.badges << Fabricate.build(:badge, badge_class_name: 'Octopussy')
    user.save!
    user
  end

  let(:github_response) do {
    'provider' => 'github',
    'uid' => 1_310_330,
    'info' => { 'nickname' => 'throwaway1',
                'email' => 'md@asdf.com',
                'name' => nil,
                'urls' => { 'GitHub' => 'https://github.com/throwaway1', 'Blog' => nil } },
    'credentials' => { 'token' => '59cdff603a4e70d47f0a28b5ccaa3935aaa790cf', 'expires' => false },
    'extra' => { 'raw_info' => { 'owned_private_repos' => 0,
                                 'type' => 'User',
                                 'avatar_url' => 'https://secure.gravatar.com/avatar/b08ed2199f8a88360c9679a57c4f9305?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png',
                                 'created_at' => '2012-01-06T20:49:02Z',
                                 'login' => 'throwaway1',
                                 'disk_usage' => 0,
                                 'plan' => { 'space' => 307_200,
                                             'private_repos' => 0,
                                             'name' => 'free',
                                             'collaborators' => 0 },
                                 'public_repos' => 0,
                                 'following' => 0,
                                 'public_gists' => 0,
                                 'followers' => 0,
                                 'gravatar_id' => 'b08ed2199f8a88360c9679a57c4f9305',
                                 'total_private_repos' => 0,
                                 'collaborators' => 0,
                                 'html_url' => 'https://github.com/throwaway1',
                                 'url' => 'https://api.github.com/users/throwaway1',
                                 'id' => 1_310_330,
                                 'private_gists' => 0 } } }.with_indifferent_access end

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
      user = User.with_username('testingReferredBy')
      expect(user.referred_by).to eq('asdfasdf')
    end

    it 'should not add referred by if not present' do
      session['oauth.data'] = github_response
      post :create, user: { location: 'SF', username: 'testingReferredBy' }
      user = User.with_username('testingReferredBy')
      expect(user.referred_by).to be_nil
    end
  end

  it 'should tracking utm UTM_CAMPAIGN on signup' do
    session[:utm_campaign] = 'asdfasdf'
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF', username: 'testingUTM_campaign' }
    user = User.with_username('testingUTM_campaign')
    expect(user.utm_campaign).to eq('asdfasdf')
  end

  it 'should capture utm_campaign if ever in params' do
    get :show, username: user.username, utm_campaign: 'asdfasdf'
    expect(session[:utm_campaign]).to eq('asdfasdf')
  end

  it 'applies oauth information to user on creation' do
    session['oauth.data'] = github_response
    post :create, user: { location: 'SF' }
    # assigns[:user].thumbnail_url == 'https://secure.gravatar.com/avatar/b08ed2199f8a88360c9679a57c4f9305'
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
    let(:linkedin_response) do {
      'provider' => 'linkedin',
      'uid' => 'DlC5AmUPnM',
      'info' => { 'first_name' => 'Matthew',
                  'last_name' => 'Deiters',
                  'name' => 'Matthew Deiters',
                  'headline' => '-',
                  'image' => 'http://media.linkedin.com/mpr/mprx/0_gPLYkP6hYm6ap1Vcxq5TkrTSYulmpzUc0tA3krFxTW5YiluBAvztoKPlKGAlx-sRyKF8wBv2M2QD',
                  'industry' => 'Computer Software',
                  'urls' => { 'public_profile' => 'http://www.linkedin.com/in/matthewdeiters' } },
      'credentials' => { 'token' => 'acafe540-606a-4f73-aef7-f6eba276603', 'secret' => 'df7427be-3d93-4563-baef-d1d38826686' },
      'extra' => { 'raw_info' => { 'firstName' => 'Matthew',
                                   'headline' => '-',
                                   'id' => 'DlC5AmUPnM',
                                   'industry' => 'Computer Software',
                                   'lastName' => 'Deiters',
                                   'pictureUrl' => 'http://media.linkedin.com/mpr/mprx/0_gPLYkP6hYm6ap1Vcxq5TkrTSYulmpzUc0tA3krFxTW5YiluBAvztoKPlKGAlx-sRyKF8wBv2M2QD',
                                   'publicProfileUrl' => 'http://www.linkedin.com/in/matthewdeiters' } } }.with_indifferent_access end

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
    let(:twitter_response) do {
      'provider' => 'twitter',
      'uid' => '6271932',
      'info' => { 'nickname' => 'mdeiters',
                  'name' => 'matthew deiters',
                  'location' => 'San Francisco',
                  'image' => 'http://a1.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg',
                  'description' => 'Dad. Amateur Foodie. Founder Extraordinaire of @coderwall',
                  'urls' => { 'Website' => 'http://coderwall.com/mdeiters', 'Twitter' => 'http://twitter.com/mdeiters' } },
      'credentials' => { 'token' => '6271932-8erxrXfJykBNMrvsdCEq5WqKd6FIcO97L9BzvPq7',
                         'secret' => '8fRS1ZARd6Wm53wvvDwHNrBmZcW0H2aSwmQjuOTHl' },
      'extra' => {
        'raw_info' => { 'lang' => 'en',
                        'profile_background_image_url' => 'http://a2.twimg.com/profile_background_images/6771536/Fresh-Grass_1600.jpg',
                        'protected' => false,
                        'time_zone' => 'Pacific Time (US & Canada)',
                        'created_at' => 'Wed May 23 21:14:29 +0000 2007',
                        'profile_link_color' => '0084B4',
                        'name' => 'matthew deiters',
                        'listed_count' => 27,
                        'contributors_enabled' => false,
                        'followers_count' => 375,
                        'profile_image_url' => 'http://a1.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg',
                        'utc_offset' => -28_800,
                        'profile_background_color' => '9AE4E8',
                        'description' => 'Dad. Amateur Foodie. Founder Extraordinaire of @coderwall',
                        'statuses_count' => 720,
                        'profile_background_tile' => false,
                        'following' => false,
                        'verified' => false,
                        'profile_sidebar_fill_color' => 'DDFFCC',
                        'status' => { 'in_reply_to_user_id' => 5_446_832,
                                      'favorited' => false, 'place' => nil,
                                      'created_at' => 'Sat Jan 07 01:57:54 +0000 2012',
                                      'retweet_count' => 0,
                                      'in_reply_to_screen_name' => 'chrislloyd',
                                      'in_reply_to_status_id_str' => '155460652457148416',
                                      'retweeted' => false,
                                      'in_reply_to_user_id_str' => '5446832',
                                      'geo' => nil,
                                      'in_reply_to_status_id' => 155_460_652_457_148_416,
                                      'id_str' => '155468169815932928',
                                      'contributors' => nil,
                                      'coordinates' => nil,
                                      'truncated' => false,
                                      'source' => "<a href=\"http://twitter.com/#!/download/iphone\" rel=\"nofollow\">Twitter for iPhone</a>",
                                      'id' => 155_468_169_815_932_928,
                                      'text' => '@minefold @chrislloyd FYI your losing seo juice with a blog sub domain' },
                        'default_profile_image' => false,
                        'friends_count' => 301,
                        'location' => 'San Francisco',
                        'screen_name' => 'mdeiters',
                        'default_profile' => false,
                        'profile_background_image_url_https' => 'https://si0.twimg.com/profile_background_images/6771536/Fresh-Grass_1600.jpg',
                        'profile_sidebar_border_color' => 'BDDCAD',
                        'id_str' => '6271932',
                        'is_translator' => false,
                        'geo_enabled' => true,
                        'url' => 'http://coderwall.com/mdeiters',
                        'profile_image_url_https' => 'https://si0.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg',
                        'profile_use_background_image' => true,
                        'favourites_count' => 178,
                        'id' => 6_271_932,
                        'show_all_inline_media' => false,
                        'follow_request_sent' => false,
                        'notifications' => false,
                        'profile_text_color' => '333333' } } }.with_indifferent_access end

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
