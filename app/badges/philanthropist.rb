class Philanthropist < BadgeBase
  describe "Philanthropist",
           skill:                   'Open Source',
           description:             "Truly improve developer quality of life by sharing at least 50 individual open source projects",
           for:                     "improving developers' quality of life by sharing at least 50 individual open source projects",
           image_name:              'philanthropist.png',
           weight:                  3,
           providers:               :github,
           required_original_repos: 50

  def reasons
    @reasons ||= if repo_count >= required_original_repos
                   "for having shared #{repo_count} individual projects."
                 else
                   ""
                 end
  end

  def award?
    !reasons.blank?
  end

  private

  def repo_count
    user.facts.select { |fact| fact.tags.include?("repo") && fact.tags.include?("original") }.size
  end
end