require 'resque/server'

Badgiy::Application.routes.draw do

  # We get 10K's of requests for this route.
  match '/.json',       to: proc { [404, {}, ['']] }
  match '/teams/.json', to: proc { [404, {}, ['']] }

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  get 'protips/update'
  put 'protips/update'

  get 'protip/update'
  put 'protip/update'

  root to: 'protips#index'
  match 'welcome' => 'home#index', as: :welcome

  mount ServeFonts.new, at: '/fonts'
  match '/p/dpvbbg' => redirect('https://coderwall.com/p/devsal')
  match '/gh' => redirect('/?utm_campaign=github_orgs_badges&utm_source=github')

  topic_regex = /[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/

  match '/comments' => 'comments#index', as: :latest_comments
  match '/jobs(/:location(/:skill))' => 'opportunities#index', as: :jobs
  match '/jobs-map' => 'opportunities#map', as: :jobs_map

  mount Split::Dashboard, at: 'split'

  resources :protips, :path => '/p', :constraints => {id: /[\dA-Z\-_]{6}/i} do
    collection { get 'random' }
    collection { get 'search' => 'protips#search', as: :search }
    collection { post 'search' => 'protips#search' }
    collection { get 'me' => 'protips#me', as: :my }
    collection { get 'admin' => 'protips#admin', as: :reviewable }
    collection { get 'team/:team_slug' => 'protips#team', as: :team }
    collection { get 'd/:date(/:start)' => 'protips#date', as: :date }
    collection { get 't/trending' => 'protips#trending', as: :trending_topics }
    collection { get 't/by_tags' => 'protips#by_tags', as: :by_tags }
    collection { get 'u/:username' => 'protips#user', as: :user }
    collection { get 't/(/*tags)' => 'networks#tag', as: :tagged }
    collection { put 't/(/*tags)/subscribe' => 'protips#subscribe', as: :subscribe }
    collection { put 't/(/*tags)/unsubscribe' => 'protips#unsubscribe', as: :unsubscribe }
    collection { get 'fresh' }
    collection { get 'trending' }
    collection { get 'popular' }
    collection { get 'liked' }
    collection { post 'preview' }

    member { post 'upvote' }
    member { post 'report_inappropriate' }
    member { post 'tag' }
    member { post 'flag' }
    member { post 'feature' }
    member { post 'queue/:queue' => 'protips#queue', as: :queue }
    member { post 'delete_tag/:topic' => 'protips#delete_tag', as: :delete_tag, :topic => topic_regex }
    resources :comments, :constraints => {id: /\d+/} do
      member { post 'like' }
    end
  end

  resources :networks, :path => '/n', :constraints => {:slug => /[\dA-Z\-]/i} do
    collection { get 'featured' => 'networks#featured', as: :featured }
    collection { get '/u/:username' => 'networks#user', as: :user }
    member { get '/t/(/*tags)' => 'networks#tag', as: :tagged }
    member { get '/members' => 'networks#members', as: :members }
    member { get '/mayor' => 'networks#mayor', as: :mayor }
    member { get '/expert' => 'networks#expert', as: :expert }
    member { post '/join' => 'networks#join', as: :join }
    member { post '/leave' => 'networks#leave', as: :leave }
    member { post '/update-tags' => 'networks#update_tags', as: :update_tags }
    member { get '/current-mayor' => 'networks#current_mayor', as: :current_mayor }
  end

  resources :processing_queues, :path => '/q' do
    member { post '/dequeue/:item' => 'processing_queues#dequeue', as: :dequeue }
  end

  match 'trending' => 'protips#index', as: :protips

  if Rails.env.development?
    match '/letter_opener' => 'letter_opener/letters#index', as: :letter_opener_letters
    match '/letter_opener/:id/:style.html' => 'letter_opener/letters#show', as: :letter_opener_letter
    mount Campaigns::Preview => 'campaigns'
    mount Notifier::Preview => 'mail'
    mount WeeklyDigest::Preview => 'digest'
    mount Subscription::Preview => 'subscription'
  end

  match 'faq' => 'pages#show', :page => :faq, as: :faq
  match 'tos' => 'pages#show', :page => :tos, as: :tos
  match 'privacy_policy' => 'pages#show', :page => :privacy_policy, as: :privacy_policy
  match 'contact_us' => 'pages#show', :page => :contact_us, as: :contact_us
  match 'api' => 'pages#show', :page => :api, as: :api
  match 'achievements' => 'pages#show', :page => :achievements, as: :achievements if Rails.env.development?
  match '/pages/:page' => 'pages#show'

  match 'award' => 'achievements#award', as: :award_badge

  match '/auth/:provider/callback' => 'sessions#create', as: :authenticate
  match '/auth/failure' => 'sessions#failure', as: :authentication_failure
  match '/settings' => 'users#edit', as: :settings
  match '/redeem/:code' => 'redemptions#show'
  match '/unsubscribe' => 'emails#unsubscribe'
  match '/delivered' => 'emails#delivered'
  match '/delete_account' => 'users#delete_account', as: :delete_account
  match '/delete_account_confirmed' => 'users#delete_account_confirmed', as: :delete_account_confirmed, :via => :post

  resources :authentications, :usernames
  resources :invitations
  match '/i/:id/:r' => 'invitations#show', as: :invitation

  resources :sessions do
    collection { get('force') }
  end

  match 'webhooks/stripe' => 'accounts#webhook'
  match '/alerts' => 'alerts#create', :via => :post
  match '/alerts' => 'alerts#index', :via => :get

  #match '/payment' => 'accounts#new', as: :payment

  match '/users/:username/follow' => 'follows#create', as: :follow_user, :type => :user, :via => :post

  match '/team/:slug' => 'teams#show', as: :teamname
  match '/team/:slug/edit' => 'teams#edit', as: :teamname_edit
  match '/team/:slug/(:job_id)' => 'teams#show', as: :job

  resources :teams do
    collection { post 'inquiry' }
    member { get 'accept' }
    member { post 'record-exit' => 'teams#record_exit', as: :record_exit }
    member { get 'visitors' }
    member { post 'follow' => 'follows#create', :type => :team }
    member { post 'join' }
    member { post 'join/:user_id/approve' => 'teams#approve_join', as: :approve_join }
    member { post 'join/:user_id/deny' => 'teams#deny_join', as: :deny_join }
    collection { get 'followed' }
    collection { get 'search' }
    resources :team_members
    resources :team_locations, as: :locations
    resources :opportunities do
      member { post 'apply' }
      member { get 'activate' }
      member { get 'deactivate' }
      member { post 'visit' }
    end
    resource :account do
      collection { post 'send_invoice' => 'accounts#send_invoice' }
    end
  end

  match '/leaderboard' => 'teams#leaderboard', as: :leaderboard
  match '/employers' => 'teams#upgrade', as: :employers

  ['github', 'twitter', 'forrst', 'dribbble', 'linkedin', 'codeplex', 'bitbucket', 'stackoverflow'].each do |provider|
    match "/#{provider}/unlink" => 'users#unlink_provider', :provider => provider, :via => :post, as: "unlink_#{provider}".to_sym
    match "/#{provider}/:username" => 'users#show', :provider => provider
  end

  resources :users do
    collection {
      post 'invite'
      get 'autocomplete'
      get 'status'
    }
    member {
      post 'specialties'
    }
    resources :skills
    resources :highlights
    resources :endorsements
    resources :pictures
    resources :follows
    resources :bans,    only: [:create]
    resources :unbans,  only: [:create]
  end

  match 'clear/:id/:provider' => 'users#clear_provider', as: :clear_provider
  match '/visual' => 'users#beta'
  match '/refresh/:username' => 'users#refresh', as: :refresh
  match '/nextaccomplishment' => 'highlights#random', as: :random_accomplishment
  match '/add-skill' => 'skills#create', as: :add_skill, :via => :post

  require_admin = ->(params, req) { User.where(id: req.session[:current_user]).first.try(:admin?) }

  scope :admin, as: :admin, :path => '/admin', :constraints => require_admin do
    match '/' => 'admin#index', as: :root
    match '/failed_jobs' => 'admin#failed_jobs'
    match '/cache_stats' => 'admin#cache_stats'
    match '/teams' => 'admin#teams', as: :teams
    match '/teams/sections/:num_sections' => 'admin#sections_teams', as: :sections_teams
    match '/teams/section/:section' => 'admin#section_teams', as: :section_teams
    mount Resque::Server.new, at: '/resque'
  end

  match '/blog' => 'blog_posts#index', as: :blog
  match '/blog/:id' => 'blog_posts#show', as: :blog_post
  match '/articles.atom' => 'blog_posts#index', as: :atom, :format => :atom

  match '/' => 'protips#index', as: :signup
  match '/signin' => 'sessions#signin', as: :signin
  match '/signout' => 'sessions#destroy', as: :signout
  match '/goodbye' => 'sessions#destroy', as: :sign_out

  match '/dashboard' => 'events#index', as: :dashboard
  match '/roll-the-dice' => 'users#randomize', as: :random_wall
  match '/trending' => 'links#index', as: :trending
  match '/:username' => 'users#show', as: :badge
  match '/:username/achievements/:id' => 'achievements#show', as: :user_achievement
  match '/:username/endorsements.json' => 'endorsements#show'
  match '/:username/followers' => 'follows#index', as: :followers, :type => :followers
  match '/:username/following' => 'follows#index', as: :following, :type => :following
  match '/:username/events' => 'events#index', as: :user_activity_feed
  match '/:username/events/more' => 'events#more'

  match '/javascripts/*filename.js' => 'legacy#show', extension: 'js'
  match '/stylesheets/*filename.css' => 'legacy#show', extension: 'css'
  match '/images/*filename.png' => 'legacy#show', extension: 'png'
  match '/images/*filename.jpg' => 'legacy#show', extension: 'jpg'

  match ':controller(/:action(/:id(.:format)))' if Rails.env.test? || Rails.env.development?

  namespace :callbacks do
    post '/hawt/feature' => 'hawt#feature'
    post '/hawt/unfeature' => 'hawt#unfeature'
  end

end
