module Repository #:nodoc:
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_a_repository(_options = {})
      include Repository::InstanceMethods
    end
  end

  # This module contains instance methods
  module InstanceMethods
    INTERFACE_METHODS = %w(provider name description repo_type size followers forks forked? languages_with_percentage contributions_of contributions raw_readme)
    CONTRIBUTION_COUNT_THRESHOLD = 10
    CONTRIBUTION_PERCENT_THRESHOLD = 0.10
    ACCEPTABLE_LANGUAGE_THRESHOLD = 1.0
    LANGUAGE_THRESHOLD_FOR_README = 10.0
    MINIMUM_REPOSITORY_SIZE = 3 * 1024

    DISABLE = nil
    REPOSITORY_TYPES = %w(personal org)
    PROJECT_TYPES = {
      'JQuery' => { matcher: /jquery/i,
                    readme_matcher: DISABLE,
                    language: 'JavaScript' },
      'Node' => { matcher: /(node.js|no.de|nodejs|(\s|\A|^)node(\s|\A|-|_|^))/i,
                  readme_matcher: DISABLE,
                  language: 'JavaScript' },
      'Prototype' => { matcher: /prototype/i,
                       readme_matcher: DISABLE,
                       language: 'JavaScript' },
      'Django' => { matcher: /django/i,
                    readme_matcher: DISABLE,
                    language: 'Python' }
    }
    INTERFACE_METHODS.each do |method|
      define_method(method) { fail NotImplementedError.new("You must implement #{method} method") }
    end

    attr_accessor :tags

    def initialize
      @tags = []
    end

    def significant?
      size >= MINIMUM_REPOSITORY_SIZE
    end

    def languages
      languages_with_percentage.keys
    end

    # Languages
    def dominant_language
      return '' if languages.blank?
      primary_language = languages_with_percentage.sort_by { |_k, v| v }.last
      if primary_language
        primary_language.first
      else
        ''
      end
    end

    def languages_that_meet_threshold
      languages_with_percentage.map do |key, value|
        key if value.to_i >= ACCEPTABLE_LANGUAGE_THRESHOLD
      end.compact
    end

    def dominant_language_percentage
      main_language = dominant_language
      bytes_of_other_langs = languages_with_percentage.map { |k, v| k != main_language ? v : 0 }.sum
      bytes_of_main_lang = languages_with_percentage[main_language]
      return 0 if bytes_of_main_lang == 0
      return 100 if bytes_of_other_langs == 0
      100 - (bytes_of_other_langs.quo(bytes_of_main_lang).to_f * 100).round
    end

    # Contributions
    def percentage_contributions_of(user_credentials)
      contributions_of(user_credentials) / contributions.to_f
    end

    def significant_contributor_to?(repo_credentials)
      contributions_of(user_credentials) >= CONTRIBUTION_COUNT_THRESHOLD || percentage_contributions_of(repo_credentials) > CONTRIBUTION_PERCENT_THRESHOLD
    end

    # Repo Status
    def popularity
      @popularity ||= begin
        rank = forks + watchers
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

    def original?
      !forked?
    end

    def has_contents?
      !languages_that_meet_threshold.blank?
    end

    def readme
      @readme ||= raw_readme
    end

    # tags and tagging
    def update_tags!
      tag_dominant_lanugage!
      tag_project_types!
      tag_repo!
      @tags.uniq!
    end

    def tag_dominant_lanugage!
      @tags << dominant_language unless languages.blank?
    end

    def tag_project_types!
      PROJECT_TYPES.each do |type, project|
        return true if tag_when_project_matches(type, project[:matcher], project[:readme_matcher], project[:language])
      end

      false
    end

    def tag_repo!
      @tags += ['repo', provider, name, repo_type]
      @tags << (forked? ? 'fork' : 'original')
    end

    def add_tag(tag)
      @tags << tag
    end

    def tagged?(tag)
      tags.include?(tag)
    end

    def tag_when_project_matches(tag_name, matcher, readme_matcher, language = nil)
      if language && dominant_language.downcase == language.downcase
        if field_matches?(name, matcher) ||
            field_matches?(description, matcher) ||
            (readme_matcher && dominant_language_percentage > LANGUAGE_THRESHOLD_FOR_README && readme_matches?(readme_matcher))
          @tags << tag_name
          return true
        end
      end
      false
    end

    def field_matches?(field, regex)
      !field.match(regex).nil?
    end

    def readme_matches?(regex)
      !readme.match(regex).nil?
    end
  end
end
