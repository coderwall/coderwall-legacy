module ProtipSearch
  extend ActiveSupport::Concern
  included do
    def to_indexed_json
      to_public_hash.deep_merge(
          {
              trending_score:        trending_score,
              popular_score:         value_score,
              score:                 score,
              upvoters:              upvoters_ids,
              comments_count:        comments.count,
              views_count:           total_views,
              comments:              comments.map do |comment|
                {
                    title: comment.title,
                    body:  comment.comment,
                    likes: comment.likes_cache
                }
              end,
              networks:              networks.map(&:name).map(&:downcase).join(","),
              best_stat:             Hash[*[:name, :value].zip(best_stat.to_a).flatten],
              team:                  user && user.team && {
                  name:         user.team.name,
                  slug:         user.team.slug,
                  avatar:       user.team.avatar_url,
                  profile_path: Rails.application.routes.url_helpers.teamname_path(slug: user.team.try(:slug)),
                  hiring:       user.team.hiring?
              },
              only_link:             only_link?,
              user:                  user && { user_id: user.id },
              flagged:               flagged?,
              created_automagically: created_automagically?,
              reviewed:              viewed_by_admin?,
              tag_ids:               topic_ids
          }
      ).to_json(methods: [:to_param])
    end

    def user_hash
      user.public_hash(true).select { |k, v| [:username, :name].include? k }.merge(
          {
              profile_url:  user.avatar_url,
              avatar:       user.avatar_url,
              profile_path: Rails.application.routes.url_helpers.badge_path(user.username),
              about:        user.about
          }
      ) unless user.nil?
    end

    def to_public_hash
      {
          public_id:   public_id,
          kind:        kind,
          title:       Sanitize.clean(title),
          body:        body,
          html:        Sanitize.clean(to_html),
          tags:        topic_list,
          upvotes:     upvotes,
          url:         path,
          upvote_path: upvote_path,
          link:        link,
          created_at:  created_at,
          featured:    featured,
          user:        user_hash
      }
    end

    def to_public_json
      to_public_hash.to_json
    end
  end

  module ClassMethods
    def trending_topics
      trending_protips = search(nil, [], page: 1, per_page: 100)

      unless trending_protips.respond_to?(:errored?) and trending_protips.errored?
        static_trending = ENV['FEATURED_TOPICS'].split(",").map(&:strip).map(&:downcase) unless ENV['FEATURED_TOPICS'].blank?
        dynamic_trending = trending_protips.flat_map { |p| p.tags }.reduce(Hash.new(0)) { |h, tag| h.tap { |h| h[tag] += 1 } }.sort { |a1, a2| a2[1] <=> a1[1] }.map { |entry| entry[0] }.reject { |tag| User.where(username: tag).any? }
        ((static_trending || []) + dynamic_trending).uniq
      else
        Tag.last(20).map(&:name).reject { |name| User.exists?(username: name) }
      end
    end

    def search_next(query, tag, index, page)
      return nil if page.nil? || (tag.blank? && query.blank?) #when your viewing a protip if we don't check this it thinks we came from trending and shows the next trending prootip eventhough we directly landed here
      page = (index.to_i * page.to_i) + 1
      tag = [tag] unless tag.is_a?(Array) || tag.nil?
      search(query, tag, page: page, per_page: 1).results.try(:first)
    end

    def search(query_string, tags =[], options={})
      query, team, author, bookmarked_by, execution, sorts= preprocess_query(query_string)
      tags = [] if tags.nil?
      tags = preprocess_tags(tags)
      tag_ids = process_tags_for_search(tags)
      tag_ids = [0] if !tags.blank? and tag_ids.blank?

      Protip.tire.index.refresh if Rails.env.test?
      filters = []
      filters << {term: {upvoters: bookmarked_by}} unless bookmarked_by.nil?
      filters << {term: {'user.user_id' => author}} unless author.nil?
      Rails.logger.debug "SEARCH: query=#{query}, tags=#{tags}, team=#{team}, author=#{author}, bookmarked_by=#{bookmarked_by}, execution=#{execution}, sorts=#{sorts} from query-string=#{query_string}, #{options.inspect}"  if ENV['DEBUG']
      begin
        tire.search(options) do
          query { string query, default_operator: 'AND', use_dis_max: true } unless query.blank?
          filter :terms, tag_ids: tag_ids, execution: execution unless tag_ids.blank?
          filter :term, teams: team unless team.nil?
          if filters.size >= 2
            filter :or, *filters
          else
            filters.each do |fltr|
              filter *fltr.first
            end
          end
          # sort { by [sorts] }
          #sort { by [{:upvotes => 'desc' }] }
        end
      rescue Tire::Search::SearchRequestFailed => e
        SearchResultsWrapper.new(nil, "Looks like our search servers are out to lunch. Try again soon.")
      end
    end

    def popular
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:popular_score),
                         nil,
                         nil).execute
    end

    def trending
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def trending_for_user(user)
      Protip::Search.new(Protip,
                         nil,
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def hawt_for_user(user)
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def hawt
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         nil,
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def trending_by_topic_tags(tags)
      trending.topics(tags.split("/"), true)
    end

    def top_trending(page = 1, per_page = PAGESIZE)
      page = 1 if page.nil?
      per_page = PAGESIZE if per_page.nil?
      search_trending_by_topic_tags(nil, [], page, per_page)
    end

    def search_trending_by_team(team_id, query_string, page, per_page)
      options = { page: page, per_page: per_page }
      force_index_commit = Protip.tire.index.refresh if Rails.env.test?
      query = "team.name:#{team_id.to_s}"
      query              += " #{query_string}" unless query_string.nil?
      Protip.search(query, [], page: page, per_page: per_page)
    rescue Errno::ECONNREFUSED
      team = Team.where(slug: team_id).first
      team.members.flat_map(&:protips)
    end

    def search_trending_by_user(username, query_string, tags, page, per_page)
      query = "author:#{username}"
      query += " #{query_string}" unless query_string.nil?
      Protip.search(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_topic_tags(query, tags, page, per_page)
      Protip.search(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_date(query, date, page, per_page)
      date_string = "#{date.midnight.strftime('%Y-%m-%dT%H:%M:%S')} TO #{(date.midnight + 1.day).strftime('%Y-%m-%dT%H:%M:%S')}" unless date.is_a?(String)
      query = "" if query.nil?
      query += " created_at:[#{date_string}]"
      Protip.search(query, [], page: page, per_page: per_page)
    end

    def search_bookmarked_protips(username, page, per_page)
      Protip.search("bookmark:#{username}", [], page: page, per_page: per_page)
    end

    def most_interesting_for(user, since=Time.at(0), page = 1, per_page = 10)
      search_top_trending_since("only_link:false", since, user.networks.flat_map(&:ordered_tags).concat(user.skills.map(&:name)), page, per_page)
    end

    def search_top_trending_since(query, since, tags, page = 1, per_page = 10)
      query ||= ""
      query += " created_at:[#{since.strftime('%Y-%m-%dT%H:%M:%S')} TO *] sort:upvotes desc"
      search_trending_by_topic_tags(query, tags, page, per_page)
    end
  end
end