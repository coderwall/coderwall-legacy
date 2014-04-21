dynamic_badges = %w(GithubGameoff TwentyFourPullRequests)

dynamic_badges.each do |klass|
  klass.constantize.load_badges
end