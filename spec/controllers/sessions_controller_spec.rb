require 'spec_helper'

RSpec.describe SessionsController, :type => :controller do
  let(:github_response) { {
      "provider" => "github",
      "uid" => 1310330,
      "info" => {"nickname" => "throwaway1",
                 "email" => nil,
                 "name" => nil,
                 "urls" => {"GitHub" => "https://github.com/throwaway1", "Blog" => nil}},
      "credentials" => {"token" => "59cdff603a4e70d47f0a28b5ccaa3935aaa790cf", "expires" => false},
      "extra" => {"raw_info" => {"owned_private_repos" => 0,
                                 "type" => "User",
                                 "avatar_url" => "https://secure.gravatar.com/avatar/b08ed2199f8a88360c9679a57c4f9305?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png",
                                 "created_at" => "2012-01-06T20:49:02Z",
                                 "login" => "throwaway1",
                                 "disk_usage" => 0,
                                 "plan" => {"space" => 307200,
                                            "private_repos" => 0,
                                            "name" => "free",
                                            "collaborators" => 0},
                                 "public_repos" => 0,
                                 "following" => 0,
                                 "public_gists" => 0,
                                 "followers" => 0,
                                 "gravatar_id" => "b08ed2199f8a88360c9679a57c4f9305",
                                 "total_private_repos" => 0,
                                 "collaborators" => 0,
                                 "html_url" => "https://github.com/throwaway1",
                                 "url" => "https://api.github.com/users/throwaway1",
                                 "id" => 1310330,
                                 "private_gists" => 0}}} }
  before :each do
    OmniAuth.config.test_mode = true
  end

  after :each do
    OmniAuth.config.test_mode = false
  end

  describe 'tracking code' do
    it 'applies the exsiting tracking code to a on sign in' do
      user = Fabricate(:user, github_id: 1310330, username: 'alreadyauser', tracking_code: nil)

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      request.cookies['trc'] = 'asdf'

      get :create
      expect(response).to redirect_to(badge_url(username: 'alreadyauser'))

      expect(user.reload.tracking_code).to eq('asdf')
    end

    it 'updates the tracking code even if the user isnt logged in' do
      user = Fabricate(:user, username: 'alreadyauser', tracking_code: 'somethingelse')
      request.cookies['identity'] = 'alreadyauser'

      get :new

      expect(response.cookies['trc']).to eq('somethingelse')
    end

    it 'updates the tracking code to the one already setup for a user' do
      request.cookies['trc'] = 'asdf'

      user = Fabricate(:user, github_id: 1310330, username: 'alreadyauser', tracking_code: 'somethingelse')
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(response).to redirect_to(badge_url(username: 'alreadyauser'))

      expect(response.cookies['trc']).to eq('somethingelse')
    end

    it 'creates a tracking code when one doesnt exist' do
      allow(controller).to receive(:mixpanel_cookie).and_return({'distinct_id' => 1234})
      user = Fabricate(:user, github_id: 1310330, username: 'alreadyauser')
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(response).to redirect_to(badge_url(username: 'alreadyauser'))
      expect(response.cookies['trc']).not_to be_blank
    end

  end

  describe 'github' do

    it 'redirects user to profile when they already have account' do
      user = Fabricate(:user, github_id: 1310330, username: 'alreadyauser')
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(response).to redirect_to(badge_url(username: 'alreadyauser'))
    end

    it 'logs oauth response if it is an unexpected structure' do
      github_response.delete('info')
      github_response.delete('uid')
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to include("Looks like something went wrong")
    end

    it 'sets up a new user and redirects to signup page' do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(response).to redirect_to(new_user_url)
    end

    it 'redirects back to profile page if user is already signed in' do
      sign_in(user = Fabricate(:user, username: 'darth'))
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github] = github_response
      get :create
      expect(flash[:notice]).to include('linked')
      expect(response).to redirect_to(badge_url(username: 'darth'))
    end
  end

  describe 'twitter' do
    let(:twitter_response) { {
        "provider" => "twitter",
        "uid" => "6271932",
        "info" => {"nickname" => "mdeiters",
                   "name" => "matthew deiters",
                   "location" => "San Francisco",
                   "image" => "http://a1.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg",
                   "description" => "Dad. Amateur Foodie. Founder Extraordinaire of @coderwall",
                   "urls" => {"Website" => "http://coderwall.com/mdeiters", "Twitter" => "http://twitter.com/mdeiters"}},
        "credentials" => {"token" => "6271932-8erxrXfJykBNMrvsdCEq5WqKd6FIcO97L9BzvPq7",
                          "secret" => "8fRS1ZARd6Wm53wvvDwHNrBmZcW0H2aSwmQjuOTHl"},
        "extra" => {
            "raw_info" => {"lang" => "en",
                           "profile_background_image_url" => "http://a2.twimg.com/profile_background_images/6771536/Fresh-Grass_1600.jpg",
                           "protected" => false,
                           "time_zone" => "Pacific Time (US & Canada)",
                           "created_at" => "Wed May 23 21:14:29 +0000 2007",
                           "profile_link_color" => "0084B4",
                           "name" => "matthew deiters",
                           "listed_count" => 27,
                           "contributors_enabled" => false,
                           "followers_count" => 375,
                           "profile_image_url" => "http://a1.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg",
                           "utc_offset" => -28800,
                           "profile_background_color" => "9AE4E8",
                           "description" => "Dad. Amateur Foodie. Founder Extraordinaire of @coderwall",
                           "statuses_count" => 720,
                           "profile_background_tile" => false,
                           "following" => false,
                           "verified" => false,
                           "profile_sidebar_fill_color" => "DDFFCC",
                           "status" => {"in_reply_to_user_id" => 5446832,
                                        "favorited" => false, "place" => nil,
                                        "created_at" => "Sat Jan 07 01:57:54 +0000 2012",
                                        "retweet_count" => 0,
                                        "in_reply_to_screen_name" => "chrislloyd",
                                        "in_reply_to_status_id_str" => "155460652457148416",
                                        "retweeted" => false,
                                        "in_reply_to_user_id_str" => "5446832",
                                        "geo" => nil,
                                        "in_reply_to_status_id" => 155460652457148416,
                                        "id_str" => "155468169815932928",
                                        "contributors" => nil,
                                        "coordinates" => nil,
                                        "truncated" => false,
                                        "source" => "<a href=\"http://twitter.com/#!/download/iphone\" rel=\"nofollow\">Twitter for iPhone</a>",
                                        "id" => 155468169815932928,
                                        "text" => "@minefold @chrislloyd FYI your losing seo juice with a blog sub domain"},
                           "default_profile_image" => false,
                           "friends_count" => 301,
                           "location" => "San Francisco",
                           "screen_name" => "mdeiters",
                           "default_profile" => false,
                           "profile_background_image_url_https" => "https://si0.twimg.com/profile_background_images/6771536/Fresh-Grass_1600.jpg",
                           "profile_sidebar_border_color" => "BDDCAD",
                           "id_str" => "6271932",
                           "is_translator" => false,
                           "geo_enabled" => true,
                           "url" => "http://coderwall.com/mdeiters",
                           "profile_image_url_https" => "https://si0.twimg.com/profile_images/1672080012/instagram_profile_normal.jpg",
                           "profile_use_background_image" => true,
                           "favourites_count" => 178,
                           "id" => 6271932,
                           "show_all_inline_media" => false,
                           "follow_request_sent" => false,
                           "notifications" => false,
                           "profile_text_color" => "333333"}}} }

    it 'does not override a users about if its already set' do
      user = Fabricate(:user, twitter_id: 6271932, username: 'alreadyauser', about: 'something original')
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] = twitter_response
      get :create
      user.reload
      expect(user.about).not_to eq('Dad. Amateur Foodie. Founder Extraordinaire of @coderwall')
      expect(user.about).to eq('something original')
    end

    it 'attempting to link an account already used should notify user' do
      exsiting_user = Fabricate(:user, twitter: 'mdeiters', twitter_id: '6271932')
      current_user = Fabricate(:user, username: 'something')
      sign_in(current_user)

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter] = twitter_response
      get :create
      expect(flash[:error]).to include('already associated with a different member')
    end
  end

end
