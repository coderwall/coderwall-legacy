require File.expand_path('../config/application', __FILE__)
require 'rake'

Coderwall::Application.load_tasks

task default: :spec

task reset_me: :environment do
  me = User.with_username('just3ws')

  # refreshable?
  refreshable = (me.achievements_checked_at.nil? || me.achievements_checked_at < 1.hour.ago)

  # me.destroy_github_cache
  GithubRepo.where('owner.github_id' => me.github_id).destroy if me.github_id
  GithubProfile.where('login' => me.github).destroy if me.github

  me.build_facts(true)
  me.reload.check_achievements!
  me.add_skills_for_unbadgified_facts
  me.calculate_score!

  GithubProfile.for_username(me.github, 1.year.ago)

  # me.destroy_github_cache
  GithubRepo.where('owner.github_id' => me.github_id).destroy if me.github_id
  GithubProfile.where('login' => me.github).destroy if me.github

  require 'pry'; binding.pry
end
