FactoryGirl.define do
  # --- User ---
  factory(:user) do
    github       'mdeiters'
    twitter      'mdeiters'
    username     { Faker::Internet.user_name.gsub(/\./, '_') }
    name         'Matthew Deiters'
    email        'someone@example.com'
    location     'San Francisco'
    github_token { Faker::Internet.ip_v4_address }
    state        { User::ACTIVE }
  end

  factory(:pending_user, class: 'User') do
    github       'bguthrie'
    username     { Faker::Internet.user_name.gsub(/\./, "_") }
    name         'Brian Guthrie'
    email        'someone@example.com'
    location     'Mountain View'
    github_token { Faker::Internet.ip_v4_address }
    state        { User::PENDING }
  end

  # --- Protip ---
  factory(:protip) do
    user

    topics %w[Javascript CoffeeScript]
    title { Faker::Company.catch_phrase }
    body { Faker::Lorem.sentences(8).join(' ') }
  end

  # --- Comment ---
  factory(:comment) do
    user
    association :commentable, factory: :protip

    comment  'Lorem Ipsum is simply dummy text...'
  end
end
