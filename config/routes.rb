require 'resque/server'

Badgiy::Application.routes.draw do

  # We get 10K's of requests for this route.
  get '/.json',       to: proc { [404, {}, ['']] }
  get '/teams/.json', to: proc { [404, {}, ['']] }

  match 'protips/update', via: %w(get put)
  match 'protip/update' , via: %w(get put)

  root to: 'protips#index'
  get 'welcome' => 'home#index', as: :welcome

  mount ServeFonts.new, at: '/fonts'
  get '/p/dpvbbg' => redirect('https://coderwall.com/p/devsal')
  get '/gh' => redirect('/?utm_campaign=github_orgs_badges&utm_source=github')

  topic_regex = /[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/

  get '/comments' => 'comments#index', as: :latest_comments
  get '/jobs(/:location(/:skill))' => 'opportunities#index', as: :jobs
  get '/jobs-map' => 'opportunities#map', as: :jobs_map

  mount Split::Dashboard, at: 'split'

  resources :protips, :path => '/p', :constraints => {id: /[\dA-Z\-_]{6}/i} do
    collection do
      get 'random'
      get 'search' => 'protips#search', as: :search
      post 'search' => 'protips#search'
      get 'me' => 'protips#me', as: :my
      get 'admin' => 'protips#admin', as: :reviewable
      get 'team/:team_slug' => 'protips#team', as: :team
      get 'd/:date(/:start)' => 'protips#date', as: :date
      get 't/trending' => 'protips#trending', as: :trending_topics
      get 't/by_tags' => 'protips#by_tags', as: :by_tags
      get 'u/:username' => 'protips#user', as: :user
      get 't/(/*tags)' => 'networks#tag', as: :tagged
      put 't/(/*tags)/subscribe' => 'protips#subscribe', as: :subscribe
      put 't/(/*tags)/unsubscribe' => 'protips#unsubscribe', as: :unsubscribe
      get 'fresh'
      get 'trending'
      get 'popular'
      get 'liked'
      post 'preview'
    end
    member do
      post 'upvote'
      post 'report_inappropriate'
      post 'tag'
      post 'flag'
      post 'feature'
      post 'queue/:queue' => 'protips#queue', as: :queue
      post 'delete_tag/:topic' => 'protips#delete_tag', as: :delete_tag, :topic => topic_regex
    end
    resources :comments, :constraints => {id: /\d+/} do
      member { post 'like' }
    end
  end

  resources :networks, :path => '/n', :constraints => {:slug => /[\dA-Z\-]/i} do
    collection do
      get 'featured' => 'networks#featured', as: :featured
      get '/u/:username' => 'networks#user', as: :user
    end
    member do
      get '/t/(/*tags)' => 'networks#tag', as: :tagged
      get '/members' => 'networks#members', as: :members
      get '/mayor' => 'networks#mayor', as: :mayor
      get '/expert' => 'networks#expert', as: :expert
      post '/join' => 'networks#join', as: :join
      post '/leave' => 'networks#leave', as: :leave
      post '/update-tags' => 'networks#update_tags', as: :update_tags
      get '/current-mayor' => 'networks#current_mayor', as: :current_mayor
    end
  end

  resources :processing_queues, :path => '/q' do
    member { post '/dequeue/:item' => 'processing_queues#dequeue', as: :dequeue }
  end

  get 'trending' => 'protips#index', as: :protips

  get 'faq' => 'pages#show', :page => :faq, as: :faq
  get 'tos' => 'pages#show', :page => :tos, as: :tos
  get 'privacy_policy' => 'pages#show', :page => :privacy_policy, as: :privacy_policy
  get 'contact_us' => 'pages#show', :page => :contact_us, as: :contact_us
  get 'api' => 'pages#show', :page => :api, as: :api
  get 'achievements' => 'pages#show', :page => :achievements, as: :achievements if Rails.env.development?
  get '/pages/:page' => 'pages#show'

  get 'award' => 'achievements#award', as: :award_badge

  get '/auth/:provider/callback' => 'sessions#create', as: :authenticate
  get '/auth/failure' => 'sessions#failure', as: :authentication_failure
  get '/settings' => 'users#edit', as: :settings
  get '/redeem/:code' => 'redemptions#show'
  get '/unsubscribe' => 'emails#unsubscribe'
  get '/delivered' => 'emails#delivered'
  get '/delete_account' => 'users#delete_account', as: :delete_account
  post '/delete_account_confirmed' => 'users#delete_account_confirmed', as: :delete_account_confirmed

  resources :authentications, :usernames
  resources :invitations
  get '/i/:id/:r' => 'invitations#show', as: :invitation

  resources :sessions do
    collection { get('force') }
  end

  get 'webhooks/stripe' => 'accounts#webhook'
  get '/alerts' => 'alerts#create', :via => :post
  get '/alerts' => 'alerts#index', :via => :get

  #get '/payment' => 'accounts#new', as: :payment

  post '/users/:username/follow' => 'follows#create', as: :follow_user, :type => :user

  get '/team/:slug' => 'teams#show', as: :teamname
  get '/team/:slug/edit' => 'teams#edit', as: :teamname_edit
  get '/team/:slug/(:job_id)' => 'teams#show', as: :job

  resources :teams do
    member do
      get 'accept'
      post 'record-exit' => 'teams#record_exit', as: :record_exit
      get 'visitors'
      post 'follow' => 'follows#create', :type => :team
      post 'join'
      post 'join/:user_id/approve' => 'teams#approve_join', as: :approve_join
      post 'join/:user_id/deny' => 'teams#deny_join', as: :deny_join
    end
    collection do
      post 'inquiry'
      get 'followed'
      get 'search'
    end
    resources :team_members
    resources :team_locations, as: :locations
    resources :opportunities do
      member do
        post 'apply'
        get 'activate'
        get 'deactivate'
        post 'visit'
      end
    end
    resource :account do
      collection { post 'send_invoice' => 'accounts#send_invoice' }
    end
  end

  get '/leaderboard' => 'teams#leaderboard', as: :leaderboard
  get '/employers' => 'teams#upgrade', as: :employers

  ['github', 'twitter', 'forrst', 'dribbble', 'linkedin', 'codeplex', 'bitbucket', 'stackoverflow'].each do |provider|
    post "/#{provider}/unlink" => 'users#unlink_provider', :provider => provider, as: "unlink_#{provider}".to_sym
    get "/#{provider}/:username" => 'users#show', :provider => provider
  end

  resources :users do
    collection do
      post 'invite'
      get 'autocomplete'
      get 'status'
    end
    member { post 'specialties' }
    resources :skills
    resources :highlights
    resources :endorsements
    resources :pictures
    resources :follows
    resources :bans,    only: [:create]
    resources :unbans,  only: [:create]
  end

  get '/clear/:id/:provider' => 'users#clear_provider', as: :clear_provider
  get '/visual' => 'users#beta'
  get '/refresh/:username' => 'users#refresh', as: :refresh
  get '/nextaccomplishment' => 'highlights#random', as: :random_accomplishment
  get '/add-skill' => 'skills#create', as: :add_skill, :via => :post

  require_admin = ->(params, req) { User.where(id: req.session[:current_user]).first.try(:admin?) }

  scope :admin, as: :admin, :path => '/admin', :constraints => require_admin do
    get '/' => 'admin#index', as: :root
    get '/failed_jobs' => 'admin#failed_jobs'
    get '/cache_stats' => 'admin#cache_stats'
    get '/teams' => 'admin#teams', as: :teams
    get '/teams/sections/:num_sections' => 'admin#sections_teams', as: :sections_teams
    get '/teams/section/:section' => 'admin#section_teams', as: :section_teams
    mount Resque::Server.new, at: '/resque'
  end

  get '/blog' => 'blog_posts#index', as: :blog
  get '/blog/:id' => 'blog_posts#show', as: :blog_post
  get '/articles.atom' => 'blog_posts#index', as: :atom, :format => :atom

  get '/' => 'protips#index', as: :signup
  get '/signin' => 'sessions#signin', as: :signin
  get '/signout' => 'sessions#destroy', as: :signout
  get '/goodbye' => 'sessions#destroy', as: :sign_out

  get '/dashboard' => 'events#index', as: :dashboard
  get '/roll-the-dice' => 'users#randomize', as: :random_wall
  get '/trending' => 'links#index', as: :trending
  get '/:username' => 'users#show', as: :badge
  get '/:username/achievements/:id' => 'achievements#show', as: :user_achievement
  get '/:username/endorsements.json' => 'endorsements#show'
  get '/:username/followers' => 'follows#index', as: :followers, :type => :followers
  get '/:username/following' => 'follows#index', as: :following, :type => :following
  get '/:username/events' => 'events#index', as: :user_activity_feed
  get '/:username/events/more' => 'events#more'

  get '/javascripts/*filename.js' => 'legacy#show', extension: 'js'
  get '/stylesheets/*filename.css' => 'legacy#show', extension: 'css'
  get '/images/*filename.png' => 'legacy#show', extension: 'png'
  get '/images/*filename.jpg' => 'legacy#show', extension: 'jpg'

  namespace :callbacks do
    post '/hawt/feature' => 'hawt#feature'
    post '/hawt/unfeature' => 'hawt#unfeature'
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
    get '/letter_opener' => 'letter_opener/letters#index', as: :letter_opener_letters
    get '/letter_opener/:id/:style.html' => 'letter_opener/letters#show', as: :letter_opener_letter
    mount Campaigns::Preview => 'campaigns'
    mount Notifier::Preview => 'mail'
    mount WeeklyDigest::Preview => 'digest'
    mount Subscription::Preview => 'subscription'
  end

end
