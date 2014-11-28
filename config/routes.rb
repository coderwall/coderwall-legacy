Coderwall::Application.routes.draw do

  # We get 10K's of requests for this route. We should configure nginx to drop these.
  get '/.json',       to: proc { [444, {}, ['']] }
  get '/teams/.json', to: proc { [444, {}, ['']] }


  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  #TODO: REMOVE
  match 'protips/update', via: %w(get put)
  match 'protip/update' , via: %w(get put)
  get 'welcome' => 'home#index', as: :welcome

  root to: 'protips#index'

  get '/p/dpvbbg', controller: :protips, action: :show, id: 'devsal'
  get '/gh' , controller: :protips, action: :show, utm_campaign: 'github_orgs_badges' , utm_source:'github'

  get '/jobs(/:location(/:skill))' => 'opportunities#index', as: :jobs
  get '/jobs-map' => 'opportunities#map', as: :jobs_map

  resources :protips, :path => '/p' do
    collection do
      get 'u/:username' => 'protips#user', as: :user
      get ':id/:slug' => 'protips#show', as: :slug, :constraints => {:slug => /(?!.*?edit).*/}
      get 'random'
      get 'search' => 'protips#search', as: :search
      post 'search' => 'protips#search'
      get 'me' => 'protips#me', as: :my
      get 'admin' => 'protips#admin', as: :reviewable
      get 'team/:team_slug' => 'protips#team', as: :team
      get 'd/:date(/:start)' => 'protips#date', as: :date
      get 't/trending' => 'protips#trending', as: :trending_topics
      get 't/by_tags' => 'protips#by_tags', as: :by_tags
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
      topic_regex = /[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/
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

  get 'trending' => 'protips#index', as: :protips

  get 'faq' => 'pages#show', :page => :faq, as: :faq
  get 'tos' => 'pages#show', :page => :tos, as: :tos
  get 'privacy_policy' => 'pages#show', :page => :privacy_policy, as: :privacy_policy
  get 'contact_us' => 'pages#show', :page => :contact_us, as: :contact_us
  get 'api' => 'pages#show', :page => :api, as: :api
  get 'achievements' => 'pages#show', :page => :achievements, as: :achievements if Rails.env.development?
  get '/pages/:page' => 'pages#show'

  get 'award' => 'achievements#award', as: :award_badge

  match '/auth/:provider/callback' => 'sessions#create', as: :authenticate, via: [:get, :post]
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
      #TODO following and unfollowing should use different HTTP verbs (:post, :delete)
      # Fix views and specs when changing this.
      post 'follow'
      post 'join'
      post 'join/:user_id/approve' => 'teams#approve_join', as: :approve_join
      post 'join/:user_id/deny' => 'teams#deny_join', as: :deny_join
    end
    collection do
      post 'inquiry'
      get 'followed'
      get 'search'
    end
    resources :members
    resources :locations, as: :locations
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

  resources :resume_uploads, only: [:create]

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
  get '/refresh/:username' => 'users#refresh', as: :refresh
  get '/nextaccomplishment' => 'highlights#random', as: :random_accomplishment
  get '/add-skill' => 'skills#create', as: :add_skill, :via => :post


  get '/blog' => 'blog_posts#index', as: :blog
  get '/blog/:id' => 'blog_posts#show', as: :blog_post
  get '/articles.atom' => 'blog_posts#index', as: :atom, :format => :atom

  get '/signin' => 'sessions#signin', as: :signin
  get '/signout' => 'sessions#destroy', as: :signout
  get '/goodbye' => 'sessions#destroy', as: :sign_out

  get '/roll-the-dice' => 'users#randomize', as: :random_wall

  get '/providers/:provider/:username' => 'provider_user_lookups#show'

  match '/404' => 'errors#not_found', via: [ :get, :post, :patch, :delete ]
  match "/422" => "errors#unacceptable", via: [ :get, :post, :patch, :delete ]
  match "/500" => "errors#internal_error", via: [ :get, :post, :patch, :delete ]

  constraints ->(params, _) { params[:username] != 'admin' } do
    get '/:username' => 'users#show', as: :badge
    get '/:username/achievements/:id' => 'achievements#show', as: :user_achievement
    get '/:username/endorsements.json' => 'endorsements#show'
    get '/:username/followers' => 'follows#index', as: :followers, :type => :followers
    get '/:username/following' => 'follows#index', as: :following, :type => :following
  end

  namespace :callbacks do
    post '/hawt/feature' => 'hawt#feature'
    post '/hawt/unfeature' => 'hawt#unfeature'
  end

  require_admin = ->(_, req) { User.where(id: req.session[:current_user], admin: true).exists? }
  scope :admin, as: :admin, :path => '/admin', :constraints => require_admin do
    get '/' => 'admin#index', as: :root
    get '/teams' => 'admin#teams', as: :teams
    get '/teams/sections/:num_sections' => 'admin#sections_teams', as: :sections_teams
    get '/teams/section/:section' => 'admin#section_teams', as: :section_teams
    mount Sidekiq::Web => '/sidekiq'
  end
  #TODO: namespace inside admin
  get '/comments' => 'comments#index', as: :latest_comments


end

# == Route Map
#
#                             GET                   /.json(.:format)                                       #<Proc:0x007fc7264beea8@/Users/mike/assemblymade/coderwall/config/routes.rb:274>
#                             GET                   /teams/.json(.:format)                                 #<Proc:0x007fc7264bccc0@/Users/mike/assemblymade/coderwall/config/routes.rb:275>
#                                                   /mail_view                                             MailPreview
#              protips_update GET|PUT               /protips/update(.:format)                              protips#update
#               protip_update GET|PUT               /protip/update(.:format)                               protip#update
#                     welcome GET                   /welcome(.:format)                                     home#index
#                        root                       /                                                      protips#index
#                    p_dpvbbg GET                   /p/dpvbbg(.:format)                                    protips#show {:id=>"devsal"}
#                          gh GET                   /gh(.:format)                                          protips#show {:utm_campaign=>"github_orgs_badges", :utm_source=>"github"}
#                        jobs GET                   /jobs(/:location(/:skill))(.:format)                   opportunities#index
#                    jobs_map GET                   /jobs-map(.:format)                                    opportunities#map
#                slug_protips GET                   /p/:id/:slug(.:format)                                 protips#show {:slug=>/(?!.*?edit).*/}
#              random_protips GET                   /p/random(.:format)                                    protips#random
#              search_protips GET                   /p/search(.:format)                                    protips#search
#                             POST                  /p/search(.:format)                                    protips#search
#                  my_protips GET                   /p/me(.:format)                                        protips#me
#          reviewable_protips GET                   /p/admin(.:format)                                     protips#admin
#                team_protips GET                   /p/team/:team_slug(.:format)                           protips#team
#                date_protips GET                   /p/d/:date(/:start)(.:format)                          protips#date
#     trending_topics_protips GET                   /p/t/trending(.:format)                                protips#trending
#             by_tags_protips GET                   /p/t/by_tags(.:format)                                 protips#by_tags
#                user_protips GET                   /p/u/:username(.:format)                               protips#user
#              tagged_protips GET                   /p/t(/*tags)(.:format)                                 networks#tag
#           subscribe_protips PUT                   /p/t(/*tags)/subscribe(.:format)                       protips#subscribe
#         unsubscribe_protips PUT                   /p/t(/*tags)/unsubscribe(.:format)                     protips#unsubscribe
#               fresh_protips GET                   /p/fresh(.:format)                                     protips#fresh
#            trending_protips GET                   /p/trending(.:format)                                  protips#trending
#             popular_protips GET                   /p/popular(.:format)                                   protips#popular
#               liked_protips GET                   /p/liked(.:format)                                     protips#liked
#             preview_protips POST                  /p/preview(.:format)                                   protips#preview
#               upvote_protip POST                  /p/:id/upvote(.:format)                                protips#upvote
# report_inappropriate_protip POST                  /p/:id/report_inappropriate(.:format)                  protips#report_inappropriate
#                  tag_protip POST                  /p/:id/tag(.:format)                                   protips#tag
#                 flag_protip POST                  /p/:id/flag(.:format)                                  protips#flag
#              feature_protip POST                  /p/:id/feature(.:format)                               protips#feature
#           delete_tag_protip POST                  /p/:id/delete_tag/:topic(.:format)                     protips#delete_tag {:topic=>/[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/}
#         like_protip_comment POST                  /p/:protip_id/comments/:id/like(.:format)              comments#like {:id=>/\d+/}
#             protip_comments GET                   /p/:protip_id/comments(.:format)                       comments#index {:id=>/\d+/}
#                             POST                  /p/:protip_id/comments(.:format)                       comments#create {:id=>/\d+/}
#          new_protip_comment GET                   /p/:protip_id/comments/new(.:format)                   comments#new {:id=>/\d+/}
#         edit_protip_comment GET                   /p/:protip_id/comments/:id/edit(.:format)              comments#edit {:id=>/\d+/}
#              protip_comment GET                   /p/:protip_id/comments/:id(.:format)                   comments#show {:id=>/\d+/}
#                             PUT                   /p/:protip_id/comments/:id(.:format)                   comments#update {:id=>/\d+/}
#                             DELETE                /p/:protip_id/comments/:id(.:format)                   comments#destroy {:id=>/\d+/}
#                     protips GET                   /p(.:format)                                           protips#index
#                             POST                  /p(.:format)                                           protips#create
#                  new_protip GET                   /p/new(.:format)                                       protips#new
#                 edit_protip GET                   /p/:id/edit(.:format)                                  protips#edit
#                      protip GET                   /p/:id(.:format)                                       protips#show
#                             PUT                   /p/:id(.:format)                                       protips#update
#                             DELETE                /p/:id(.:format)                                       protips#destroy
#           featured_networks GET                   /n/featured(.:format)                                  networks#featured {:slug=>/[\dA-Z\-]/i}
#               user_networks GET                   /n/u/:username(.:format)                               networks#user {:slug=>/[\dA-Z\-]/i}
#              tagged_network GET                   /n/:id/t(/*tags)(.:format)                             networks#tag {:slug=>/[\dA-Z\-]/i}
#             members_network GET                   /n/:id/members(.:format)                               networks#members {:slug=>/[\dA-Z\-]/i}
#               mayor_network GET                   /n/:id/mayor(.:format)                                 networks#mayor {:slug=>/[\dA-Z\-]/i}
#              expert_network GET                   /n/:id/expert(.:format)                                networks#expert {:slug=>/[\dA-Z\-]/i}
#                join_network POST                  /n/:id/join(.:format)                                  networks#join {:slug=>/[\dA-Z\-]/i}
#               leave_network POST                  /n/:id/leave(.:format)                                 networks#leave {:slug=>/[\dA-Z\-]/i}
#         update_tags_network POST                  /n/:id/update-tags(.:format)                           networks#update_tags {:slug=>/[\dA-Z\-]/i}
#       current_mayor_network GET                   /n/:id/current-mayor(.:format)                         networks#current_mayor {:slug=>/[\dA-Z\-]/i}
#                    networks GET                   /n(.:format)                                           networks#index {:slug=>/[\dA-Z\-]/i}
#                             POST                  /n(.:format)                                           networks#create {:slug=>/[\dA-Z\-]/i}
#                 new_network GET                   /n/new(.:format)                                       networks#new {:slug=>/[\dA-Z\-]/i}
#                edit_network GET                   /n/:id/edit(.:format)                                  networks#edit {:slug=>/[\dA-Z\-]/i}
#                     network GET                   /n/:id(.:format)                                       networks#show {:slug=>/[\dA-Z\-]/i}
#                             PUT                   /n/:id(.:format)                                       networks#update {:slug=>/[\dA-Z\-]/i}
#                             DELETE                /n/:id(.:format)                                       networks#destroy {:slug=>/[\dA-Z\-]/i}
#                     protips GET                   /trending(.:format)                                    protips#index
#                         faq GET                   /faq(.:format)                                         pages#show {:page=>:faq}
#                         tos GET                   /tos(.:format)                                         pages#show {:page=>:tos}
#              privacy_policy GET                   /privacy_policy(.:format)                              pages#show {:page=>:privacy_policy}
#                  contact_us GET                   /contact_us(.:format)                                  pages#show {:page=>:contact_us}
#                         api GET                   /api(.:format)                                         pages#show {:page=>:api}
#                achievements GET                   /achievements(.:format)                                pages#show {:page=>:achievements}
#                             GET                   /pages/:page(.:format)                                 pages#show
#                 award_badge GET                   /award(.:format)                                       achievements#award
#                authenticate GET|POST              /auth/:provider/callback(.:format)                     sessions#create
#      authentication_failure GET                   /auth/failure(.:format)                                sessions#failure
#                    settings GET                   /settings(.:format)                                    users#edit
#                             GET                   /redeem/:code(.:format)                                redemptions#show
#                 unsubscribe GET                   /unsubscribe(.:format)                                 emails#unsubscribe
#                   delivered GET                   /delivered(.:format)                                   emails#delivered
#              delete_account GET                   /delete_account(.:format)                              users#delete_account
#    delete_account_confirmed POST                  /delete_account_confirmed(.:format)                    users#delete_account_confirmed
#             authentications GET                   /authentications(.:format)                             authentications#index
#                             POST                  /authentications(.:format)                             authentications#create
#          new_authentication GET                   /authentications/new(.:format)                         authentications#new
#         edit_authentication GET                   /authentications/:id/edit(.:format)                    authentications#edit
#              authentication GET                   /authentications/:id(.:format)                         authentications#show
#                             PUT                   /authentications/:id(.:format)                         authentications#update
#                             DELETE                /authentications/:id(.:format)                         authentications#destroy
#                   usernames GET                   /usernames(.:format)                                   usernames#index
#                             POST                  /usernames(.:format)                                   usernames#create
#                new_username GET                   /usernames/new(.:format)                               usernames#new
#               edit_username GET                   /usernames/:id/edit(.:format)                          usernames#edit
#                    username GET                   /usernames/:id(.:format)                               usernames#show
#                             PUT                   /usernames/:id(.:format)                               usernames#update
#                             DELETE                /usernames/:id(.:format)                               usernames#destroy
#                 invitations GET                   /invitations(.:format)                                 invitations#index
#                             POST                  /invitations(.:format)                                 invitations#create
#              new_invitation GET                   /invitations/new(.:format)                             invitations#new
#             edit_invitation GET                   /invitations/:id/edit(.:format)                        invitations#edit
#                  invitation GET                   /invitations/:id(.:format)                             invitations#show
#                             PUT                   /invitations/:id(.:format)                             invitations#update
#                             DELETE                /invitations/:id(.:format)                             invitations#destroy
#                  invitation GET                   /i/:id/:r(.:format)                                    invitations#show
#              force_sessions GET                   /sessions/force(.:format)                              sessions#force
#                    sessions GET                   /sessions(.:format)                                    sessions#index
#                             POST                  /sessions(.:format)                                    sessions#create
#                 new_session GET                   /sessions/new(.:format)                                sessions#new
#                edit_session GET                   /sessions/:id/edit(.:format)                           sessions#edit
#                     session GET                   /sessions/:id(.:format)                                sessions#show
#                             PUT                   /sessions/:id(.:format)                                sessions#update
#                             DELETE                /sessions/:id(.:format)                                sessions#destroy
#             webhooks_stripe GET                   /webhooks/stripe(.:format)                             accounts#webhook
#                      alerts GET                   /alerts(.:format)                                      alerts#create
#                             GET                   /alerts(.:format)                                      alerts#index
#                 follow_user POST                  /users/:username/follow(.:format)                      follows#create {:type=>:user}
#                    teamname GET                   /team/:slug(.:format)                                  teams#show
#               teamname_edit GET                   /team/:slug/edit(.:format)                             teams#edit
#                         job GET                   /team/:slug(/:job_id)(.:format)                        teams#show
#                 accept_team GET                   /teams/:id/accept(.:format)                            teams#accept
#            record_exit_team POST                  /teams/:id/record-exit(.:format)                       teams#record_exit
#               visitors_team GET                   /teams/:id/visitors(.:format)                          teams#visitors
#                 follow_team POST                  /teams/:id/follow(.:format)                            teams#follow
#                   join_team POST                  /teams/:id/join(.:format)                              teams#join
#           approve_join_team POST                  /teams/:id/join/:user_id/approve(.:format)             teams#approve_join
#              deny_join_team POST                  /teams/:id/join/:user_id/deny(.:format)                teams#deny_join
#               inquiry_teams POST                  /teams/inquiry(.:format)                               teams#inquiry
#              followed_teams GET                   /teams/followed(.:format)                              teams#followed
#                search_teams GET                   /teams/search(.:format)                                teams#search
#                team_members GET                   /teams/:team_id/members(.:format)                      members#index
#                             POST                  /teams/:team_id/members(.:format)                      members#create
#             new_team_member GET                   /teams/:team_id/members/new(.:format)                  members#new
#            edit_team_member GET                   /teams/:team_id/members/:id/edit(.:format)             members#edit
#                 team_member GET                   /teams/:team_id/members/:id(.:format)                  members#show
#                             PUT                   /teams/:team_id/members/:id(.:format)                  members#update
#                             DELETE                /teams/:team_id/members/:id(.:format)                  members#destroy
#              team_locations GET                   /teams/:team_id/locations(.:format)                    locations#index
#                             POST                  /teams/:team_id/locations(.:format)                    locations#create
#           new_team_location GET                   /teams/:team_id/locations/new(.:format)                locations#new
#          edit_team_location GET                   /teams/:team_id/locations/:id/edit(.:format)           locations#edit
#               team_location GET                   /teams/:team_id/locations/:id(.:format)                locations#show
#                             PUT                   /teams/:team_id/locations/:id(.:format)                locations#update
#                             DELETE                /teams/:team_id/locations/:id(.:format)                locations#destroy
#      apply_team_opportunity POST                  /teams/:team_id/opportunities/:id/apply(.:format)      opportunities#apply
#   activate_team_opportunity GET                   /teams/:team_id/opportunities/:id/activate(.:format)   opportunities#activate
# deactivate_team_opportunity GET                   /teams/:team_id/opportunities/:id/deactivate(.:format) opportunities#deactivate
#      visit_team_opportunity POST                  /teams/:team_id/opportunities/:id/visit(.:format)      opportunities#visit
#          team_opportunities GET                   /teams/:team_id/opportunities(.:format)                opportunities#index
#                             POST                  /teams/:team_id/opportunities(.:format)                opportunities#create
#        new_team_opportunity GET                   /teams/:team_id/opportunities/new(.:format)            opportunities#new
#       edit_team_opportunity GET                   /teams/:team_id/opportunities/:id/edit(.:format)       opportunities#edit
#            team_opportunity GET                   /teams/:team_id/opportunities/:id(.:format)            opportunities#show
#                             PUT                   /teams/:team_id/opportunities/:id(.:format)            opportunities#update
#                             DELETE                /teams/:team_id/opportunities/:id(.:format)            opportunities#destroy
#   send_invoice_team_account POST                  /teams/:team_id/account/send_invoice(.:format)         accounts#send_invoice
#                team_account POST                  /teams/:team_id/account(.:format)                      accounts#create
#            new_team_account GET                   /teams/:team_id/account/new(.:format)                  accounts#new
#           edit_team_account GET                   /teams/:team_id/account/edit(.:format)                 accounts#edit
#                             GET                   /teams/:team_id/account(.:format)                      accounts#show
#                             PUT                   /teams/:team_id/account(.:format)                      accounts#update
#                             DELETE                /teams/:team_id/account(.:format)                      accounts#destroy
#                       teams GET                   /teams(.:format)                                       teams#index
#                             POST                  /teams(.:format)                                       teams#create
#                    new_team GET                   /teams/new(.:format)                                   teams#new
#                   edit_team GET                   /teams/:id/edit(.:format)                              teams#edit
#                        team GET                   /teams/:id(.:format)                                   teams#show
#                             PUT                   /teams/:id(.:format)                                   teams#update
#                             DELETE                /teams/:id(.:format)                                   teams#destroy
#                 leaderboard GET                   /leaderboard(.:format)                                 teams#leaderboard
#                   employers GET                   /employers(.:format)                                   teams#upgrade
#               unlink_github POST                  /github/unlink(.:format)                               users#unlink_provider {:provider=>"github"}
#                             GET                   /github/:username(.:format)                            users#show {:provider=>"github"}
#              unlink_twitter POST                  /twitter/unlink(.:format)                              users#unlink_provider {:provider=>"twitter"}
#                             GET                   /twitter/:username(.:format)                           users#show {:provider=>"twitter"}
#               unlink_forrst POST                  /forrst/unlink(.:format)                               users#unlink_provider {:provider=>"forrst"}
#                             GET                   /forrst/:username(.:format)                            users#show {:provider=>"forrst"}
#             unlink_dribbble POST                  /dribbble/unlink(.:format)                             users#unlink_provider {:provider=>"dribbble"}
#                             GET                   /dribbble/:username(.:format)                          users#show {:provider=>"dribbble"}
#             unlink_linkedin POST                  /linkedin/unlink(.:format)                             users#unlink_provider {:provider=>"linkedin"}
#                             GET                   /linkedin/:username(.:format)                          users#show {:provider=>"linkedin"}
#             unlink_codeplex POST                  /codeplex/unlink(.:format)                             users#unlink_provider {:provider=>"codeplex"}
#                             GET                   /codeplex/:username(.:format)                          users#show {:provider=>"codeplex"}
#            unlink_bitbucket POST                  /bitbucket/unlink(.:format)                            users#unlink_provider {:provider=>"bitbucket"}
#                             GET                   /bitbucket/:username(.:format)                         users#show {:provider=>"bitbucket"}
#        unlink_stackoverflow POST                  /stackoverflow/unlink(.:format)                        users#unlink_provider {:provider=>"stackoverflow"}
#                             GET                   /stackoverflow/:username(.:format)                     users#show {:provider=>"stackoverflow"}
#              resume_uploads POST                  /resume_uploads(.:format)                              resume_uploads#create
#                invite_users POST                  /users/invite(.:format)                                users#invite
#          autocomplete_users GET                   /users/autocomplete(.:format)                          users#autocomplete
#                status_users GET                   /users/status(.:format)                                users#status
#            specialties_user POST                  /users/:id/specialties(.:format)                       users#specialties
#                 user_skills GET                   /users/:user_id/skills(.:format)                       skills#index
#                             POST                  /users/:user_id/skills(.:format)                       skills#create
#              new_user_skill GET                   /users/:user_id/skills/new(.:format)                   skills#new
#             edit_user_skill GET                   /users/:user_id/skills/:id/edit(.:format)              skills#edit
#                  user_skill GET                   /users/:user_id/skills/:id(.:format)                   skills#show
#                             PUT                   /users/:user_id/skills/:id(.:format)                   skills#update
#                             DELETE                /users/:user_id/skills/:id(.:format)                   skills#destroy
#             user_highlights GET                   /users/:user_id/highlights(.:format)                   highlights#index
#                             POST                  /users/:user_id/highlights(.:format)                   highlights#create
#          new_user_highlight GET                   /users/:user_id/highlights/new(.:format)               highlights#new
#         edit_user_highlight GET                   /users/:user_id/highlights/:id/edit(.:format)          highlights#edit
#              user_highlight GET                   /users/:user_id/highlights/:id(.:format)               highlights#show
#                             PUT                   /users/:user_id/highlights/:id(.:format)               highlights#update
#                             DELETE                /users/:user_id/highlights/:id(.:format)               highlights#destroy
#           user_endorsements GET                   /users/:user_id/endorsements(.:format)                 endorsements#index
#                             POST                  /users/:user_id/endorsements(.:format)                 endorsements#create
#        new_user_endorsement GET                   /users/:user_id/endorsements/new(.:format)             endorsements#new
#       edit_user_endorsement GET                   /users/:user_id/endorsements/:id/edit(.:format)        endorsements#edit
#            user_endorsement GET                   /users/:user_id/endorsements/:id(.:format)             endorsements#show
#                             PUT                   /users/:user_id/endorsements/:id(.:format)             endorsements#update
#                             DELETE                /users/:user_id/endorsements/:id(.:format)             endorsements#destroy
#               user_pictures GET                   /users/:user_id/pictures(.:format)                     pictures#index
#                             POST                  /users/:user_id/pictures(.:format)                     pictures#create
#            new_user_picture GET                   /users/:user_id/pictures/new(.:format)                 pictures#new
#           edit_user_picture GET                   /users/:user_id/pictures/:id/edit(.:format)            pictures#edit
#                user_picture GET                   /users/:user_id/pictures/:id(.:format)                 pictures#show
#                             PUT                   /users/:user_id/pictures/:id(.:format)                 pictures#update
#                             DELETE                /users/:user_id/pictures/:id(.:format)                 pictures#destroy
#                user_follows GET                   /users/:user_id/follows(.:format)                      follows#index
#                             POST                  /users/:user_id/follows(.:format)                      follows#create
#             new_user_follow GET                   /users/:user_id/follows/new(.:format)                  follows#new
#            edit_user_follow GET                   /users/:user_id/follows/:id/edit(.:format)             follows#edit
#                 user_follow GET                   /users/:user_id/follows/:id(.:format)                  follows#show
#                             PUT                   /users/:user_id/follows/:id(.:format)                  follows#update
#                             DELETE                /users/:user_id/follows/:id(.:format)                  follows#destroy
#                   user_bans POST                  /users/:user_id/bans(.:format)                         bans#create
#                 user_unbans POST                  /users/:user_id/unbans(.:format)                       unbans#create
#                       users GET                   /users(.:format)                                       users#index
#                             POST                  /users(.:format)                                       users#create
#                    new_user GET                   /users/new(.:format)                                   users#new
#                   edit_user GET                   /users/:id/edit(.:format)                              users#edit
#                        user GET                   /users/:id(.:format)                                   users#show
#                             PUT                   /users/:id(.:format)                                   users#update
#                             DELETE                /users/:id(.:format)                                   users#destroy
#              clear_provider GET                   /clear/:id/:provider(.:format)                         users#clear_provider
#                     refresh GET                   /refresh/:username(.:format)                           users#refresh
#       random_accomplishment GET                   /nextaccomplishment(.:format)                          highlights#random
#                   add_skill GET                   /add-skill(.:format)                                   skills#create
#                        blog GET                   /blog(.:format)                                        blog_posts#index
#                   blog_post GET                   /blog/:id(.:format)                                    blog_posts#show
#                        atom GET                   /articles.atom(.:format)                               blog_posts#index {:format=>:atom}
#                      signin GET                   /signin(.:format)                                      sessions#signin
#                     signout GET                   /signout(.:format)                                     sessions#destroy
#                    sign_out GET                   /goodbye(.:format)                                     sessions#destroy
#                 random_wall GET                   /roll-the-dice(.:format)                               users#randomize
#                             GET                   /providers/:provider/:username(.:format)               provider_user_lookups#show
#                             GET|POST|PATCH|DELETE /404(.:format)                                         errors#not_found
#                             GET|POST|PATCH|DELETE /422(.:format)                                         errors#unacceptable
#                             GET|POST|PATCH|DELETE /500(.:format)                                         errors#internal_error
#                       badge GET                   /:username(.:format)                                   users#show
#            user_achievement GET                   /:username/achievements/:id(.:format)                  achievements#show
#                             GET                   /:username/endorsements.json(.:format)                 endorsements#show
#                   followers GET                   /:username/followers(.:format)                         follows#index {:type=>:followers}
#                   following GET                   /:username/following(.:format)                         follows#index {:type=>:following}
#      callbacks_hawt_feature POST                  /callbacks/hawt/feature(.:format)                      callbacks/hawt#feature
#    callbacks_hawt_unfeature POST                  /callbacks/hawt/unfeature(.:format)                    callbacks/hawt#unfeature
#                  admin_root GET                   /admin(.:format)                                       admin#index
#                 admin_teams GET                   /admin/teams(.:format)                                 admin#teams
#        admin_sections_teams GET                   /admin/teams/sections/:num_sections(.:format)          admin#sections_teams
#         admin_section_teams GET                   /admin/teams/section/:section(.:format)                admin#section_teams
#           admin_sidekiq_web                       /admin/sidekiq                                         Sidekiq::Web
#             latest_comments GET                   /comments(.:format)                                    comments#index
#
