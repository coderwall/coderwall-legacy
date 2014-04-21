class LanguageBadge < BadgeBase
  describe 'Language badge',
           language_required: lambda { raise "Not implemented" },
           number_required:   lambda { raise "Not implemented" }

  def reasons
    @reasons ||= begin
      links = []
      found = user.facts.select do |fact|
        fact.tagged?('personal', 'repo', 'original', language_required)
      end
      found.each do |fact|
        links << { fact.name => fact.url }
      end
      { links: links }
    end
  end

  def award?
    reasons[:links].size >= number_required
  end

end