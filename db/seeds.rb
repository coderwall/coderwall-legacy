Protip.skip_callback(:save, :before, :hawt!)

module S
  def self.create_protip_for(user)
    yield protip = user.protips.build
    protip.save!
  end

  def self.create_network_for(name)
    Network.find_or_create_by_name(name) do |n|
      n.create_slug!
    end
  end
end

puts '---- NETWORKS ----'

S.create_network_for('Ruby')
S.create_network_for('JavaScript')

puts '---- PLANS ----'

Plan.find_or_create_by_id(1) do |s|
  s.amount    = 0
  s.interval  = 'month'
  s.name      = 'Basic'
  s.currency  = 'usd'
  s.public_id = 'sisv2w'
  s.analytics = false
end

Plan.find_or_create_by_id(2) do |s|
  s.amount    = 9900
  s.interval  = 'month'
  s.name      = 'Monthly'
  s.currency  = 'usd'
  s.public_id = 'eq6v5q'
  s.analytics = false
end

Plan.find_or_create_by_id(3) do |s|
  s.amount    = 19900
  s.interval  = nil
  s.name      = 'Single'
  s.currency  = 'usd'
  s.public_id = 'ryew8a'
  s.analytics = false
end

Plan.find_or_create_by_id(4) do |s|
  s.amount    = 19900
  s.interval  = 'month'
  s.name      = 'Analytics'
  s.currency  = 'usd'
  s.public_id = 'qr5rxa'
  s.analytics = true
end

puts '---- USERS ----'

admin = User.find_or_create_by_id(1) do |s|
  s.admin      = true
  s.state      = User::ACTIVE

  s.name       = 'Administrator'
  s.username   = 'Administrator'

  s.location   = 'San Francisco, CA'
  s.country    = 'United States'
  s.state_name = 'California'
  s.lat        = 37.7749295
  s.lng        = -122.4194155

  s.api_key    = '1276acefb7181a64'
end

bryce = User.find_or_create_by_email('bryce.shivers@putabirdonit.com') do |s|
  s.admin      = false
  s.state      = User::ACTIVE

  s.name       = 'Bryce Shivers'
  s.username   = 'bryce'

  s.location   = 'Portland, Oregon'
  s.city       = 'Portland'
  s.country    = 'United States'
  s.state_name = 'Oregon'
  s.lat        = 45.5234515
  s.lng        = -122.6762071

  s.title      = 'Co-artisan'
  s.company    = 'Put a Bird on It'

  s.api_key    = '09d05d2dc824208c'
end

lisa = User.find_or_create_by_email('lisa.eversman@putabirdonit.com') do |s|
  s.admin      = false
  s.state      = User::ACTIVE

  s.name       = 'Lisa Eversman'
  s.username   = 'lisa'

  s.location   = 'Portland, Oregon'
  s.city       = 'Portland'
  s.country    = 'United States'
  s.state_name = 'Oregon'
  s.lat        = 45.5234515
  s.lng        = -122.6762071

  s.title      = 'Co-artisan'
  s.company    = 'Put a Bird on It'

  s.api_key    = 'a1536331c20aad4d'
end

puts '---- PROTIPS ----'


S.create_protip_for(bryce) do |p|
  p.title  = 'Suspendisse potenti'
  p.body   = '<p>Suspendisse potenti. Nunc iaculis risus vel &#8216;Orci Ornare&#8217; dignissim sed vitae nulla. Nulla lobortis tempus commodo. Suspendisse <em>potenti</em>. Duis sagittis, est sit amet gravida tristique, purus lectus venenatis urna, id &#8216;molestie&#8217; magna risus ut nunc. Donec tempus tempus tellus, ac <abbr title="Hypertext Markup Language">HTML</abbr> lacinia turpis mattis ac. Fusce ac sodales magna. Fusce ac sodales <abbr title="Cascading Style Sheets">CSS</abbr> magna.</p>'
  p.topic_list = %w{suspendisse potenti}
end

S.create_protip_for(bryce) do |p|
  p.title  = 'Vinyl Blue Bottle four loko wayfarers'
  p.body   = 'Austin try-hard artisan, bicycle rights salvia squid dreamcatcher hoodie before they sold out Carles scenester ennui. Organic mumblecore Tumblr, gentrify retro 90\'s fanny pack flexitarian raw denim roof party cornhole. Hella direct trade mixtape +1 cliche, slow-carb Neutra craft beer tousled fap DIY.'
  p.topic_list = %w{etsy hipster}
end

S.create_protip_for(lisa) do |p|
  p.title  = 'Cras molestie risus a enim convallis vitae luctus libero lacinia'
  p.body   = '<p>Cras molestie risus a enim convallis vitae luctus libero lacinia. Maecenas sit <q cite="http://www.heydonworks.com">amet tellus nec mi gravida posuere</q> non pretium magna. Nulla vel magna sit amet dui <a href="#">lobortis</a> commodo vitae vel nulla. </p>'
  p.topic_list = %w{cras molestie}
end

puts '---- TEAMS ----'

team_name = 'Put a Bird on It'
paboi = Team.where(name: team_name).try(:first) || Team.create!(name: team_name)
paboi.add_member(lisa)
paboi.add_member(bryce)

paboi.benefit_name_1 = 'Putting birds on things.'
paboi.big_quote = 'The dream of the 90s is alive in Portland!'
paboi.featured_banner_image = 'http://images.amcnetworks.com/ifc.com/wp-content/uploads/2011/05/portlandia-put-a-bird-on-it-ifc.jpg'
paboi.headline = 'We put birds on things!'
paboi.hiring_tagline = 'Put a bird on it!'
paboi.interview_steps = [ 'Do you like to put birds on things?' ]
paboi.our_challenge = 'Keep the dream of the 90\'s alive!'
paboi.reason_description_1 = 'Do you dream of the 90\'s?'
paboi.reason_name_1 = 'Because flannel.'
paboi.reason_name_2 = 'Because the tattoo ink never runs dry.'
paboi.reason_name_3 = 'Because you can sleep \'till 11.'
paboi.slug = 'put-a-bird-on-it'
paboi.stack_list = 'Birds, Crafts'
paboi.your_impact = 'We put birds on things to make them better.'
paboi.benefit_description_1 = 'Get to put birds on things.'
paboi.blog_feed = 'http://portlandiamom.blogspot.com/feeds/posts/default?alt=rss'

paboi.save!

unless Rails.env.staging? || Rails.env.production?
  #Network.rebuild_index
  Opportunity.rebuild_index
  Protip.rebuild_index

  #Team.rebuild_index #TODO: Disabled until switched from mongo
  Team.all.each { |team| team.tire.update_index }
end
