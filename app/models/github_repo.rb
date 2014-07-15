class GithubRepo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :html_url, type: String
  field :tags, type: Array, default: []
  field :languages
  field :fork, type: Boolean
  field :forks
  field :pushed_at
  field :watchers

  embeds_one :owner, class_name: GithubUser.name.to_s, as: :personable
  embeds_many :followers, class_name: GithubUser.name.to_s, as: :personable
  embeds_many :contributors, class_name: GithubUser.name.to_s, as: :personable

  index('owner.login' => 1)
  index('owner.github_id' => 1)
  index(name: 1)

  before_save :update_tags!

  class << self
    def for_owner_and_name(owner, name, client = nil, prefetched = {})
      (where('owner.login' => owner, 'name' => name).first || new('name' => name, 'owner' => { 'login' => owner })).tap do |repo|
        if repo.new_record?
          logger.info "ALERT: No cached repo for #{owner}/#{name}"
          repo.refresh!(client, prefetched)
        end
      end
    end
  end

  def refresh!(client = nil, repo = {})
    client      ||= Github.new
    owner, name = self.owner.login, self.name

    repo        = client.repo(owner, name) if repo.empty?

    if repo[:fork].blank?
      repo.merge!(
        forks:        client.repo_forks(owner, name),
        contributors: client.repo_contributors(owner, name),
      )
    end

    repo.delete(:id)

    update_attributes! repo.merge(
                         owner:     GithubUser.new(repo[:owner]),
                         followers: client.repo_watchers(owner, name),
                         languages: client.repo_languages(owner, name) # needed so we can determine contents
                       )
  end

  def full_name
    "#{owner.login}/#{name}"
  end

  def times_forked
    if self[:forks].is_a? Array
      self[:forks].size
    else
      self[:forks] || 0
    end
  end

  def dominant_language_percentage
    main_language        = dominant_language
    bytes_of_other_langs = languages.map { |k, v| k != main_language ? v : 0 }.sum
    bytes_of_main_lang   = languages[main_language]
    return 0 if bytes_of_main_lang == 0
    return 100 if bytes_of_other_langs == 0
    100 - (bytes_of_other_langs.quo(bytes_of_main_lang).to_f * 100).round
  end

  def total_commits
    contributors.to_a.sum do |c|
      c['contributions']
    end
  end

  def total_contributions_for(github_id)
    contributor = contributors.first { |c| c['github_id'] == github_id }
    (contributor && contributor['contributions']) || 0
  end

  CONTRIBUTION_COUNT_THRESHOLD   = 10
  CONTRIBUTION_PERCENT_THRESHOLD = 0.10

  def percent_contributions_for(github_id)
    total_contributions_for(github_id) / total_commits.to_f
  end

  def significant_contributions?(github_id)
    total_contributions_for(github_id) >= CONTRIBUTION_COUNT_THRESHOLD || percent_contributions_for(github_id) > CONTRIBUTION_PERCENT_THRESHOLD
  end

  def dominant_language
    return '' if languages.blank?
    primary_language = languages.sort_by { |_k, v| v }.last
    if primary_language
      primary_language.first
    else
      ''
    end
  end

  def languages_that_meet_threshold
    languages.map do |key, value|
      key if value.to_i >= 200
    end.compact
  end

  def original?
    !fork?
  end

  def has_contents?
    !languages_that_meet_threshold.blank?
  end

  def readme
    @readme ||= raw_readme
  end

  def popularity
    @popularity ||= begin
      rank = times_forked + watchers # (times_forked + followers.size)
      case
        when rank > 600 then
          5
        when rank > 300 then
          4
        when rank > 100 then
          3
        when rank > 20 then
          2
        else
          1
      end
    end
  end

  def raw_readme
    %w(
      README
      README.markdown
      README.md
      README.txt
    ).each do |file_type|
      begin
        return Servant.get("#{html_url}/raw/master/#{file_type}").result
      rescue RestClient::ResourceNotFound
        Rails.logger.debug("Looking for readme, did not find #{file_type}")
      end
    end
    empty_string = ''
  end

  def update_tags!
    tag_dominant_lanugage!
    tag_project_types!
    tags.uniq!
  end

  def tag_dominant_lanugage!
    tags << dominant_language unless languages.blank?
  end

  def add_tag(tag)
    tags << tag
  end

  def tagged?(tag)
    tags.include?(tag)
  end

  NODE_MATCHER   = /(node.js|no.de|nodejs|(\s|\A|^)node(\s|\A|-|_|^))/i
  JQUERY_MATCHER = /jquery/i

  def tag_project_types!
    tag_when_project_matches('JQuery', JQUERY_MATCHER, disable_readme_inspection = nil, 'JavaScript') ||
      tag_when_project_matches('Node', NODE_MATCHER, disable_readme_inspection = nil, 'JavaScript') ||
      tag_when_project_matches('Prototype', /prototype/i, nil, 'JavaScript')
  end

  def tag_when_project_matches(tag_name, matcher, readme_matcher, language = nil)
    if language && dominant_language.downcase == language.downcase
      if field_matches?('name', matcher) ||
        field_matches?('description', matcher) ||
        (readme_matcher && dominant_language_percentage > 90 && readme_matches?(readme_matcher))
        tags << tag_name
        return true
      end
    end
    false
  end

  def field_matches?(field, regex)
    self[field] && !self[field].match(regex).nil?
  end

  def readme_matches?(regex)
    !readme.match(regex).nil?
  end
end
