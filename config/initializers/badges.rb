dynamic_badges = %w(GithubGameoff TwentyFourPullRequests)

dynamic_badges.each do |klass|
  klass.constantize.load_badges
end

BADGES_LIST ||= ObjectSpace.enum_for(:each_object, class << BadgeBase; self; end).map(&:to_s) - %w{BadgeBase}
