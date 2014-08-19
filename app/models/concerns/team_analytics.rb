module TeamAnalytics
  extend ActiveSupport::Concern
  # TODO, Get out out redis
  included do
    SECTIONS = %w(team-details members about-members big-headline big-quote challenges favourite-benefits
                        organization-style office-images jobs stack protips why-work interview-steps
                        locations team-blog)

    def record_exit(viewer, exit_url, exit_target_type, furthest_scrolled, time_spent)
      epoch_now = Time.now.to_i
      user_id = (viewer.respond_to?(:id) && viewer.try(:id)) || viewer
      data = visitor_data(exit_url, exit_target_type, furthest_scrolled, time_spent, user_id, epoch_now, nil)
      Redis.current.zadd(user_detail_views_key, epoch_now, data)
    end

    def detailed_visitors(since = 0)
      Redis.current.zrangebyscore(user_detail_views_key, since, Time.now.to_i).map do |visitor_string|
        visitor = some_crappy_method(visitor_string)
        visitor[:user] = identify_visitor(visitor[:user_id])
        visitor
      end
    end

    def simple_visitors(since = 0)
      all_visitors = Redis.current.zrangebyscore(user_views_key, since, Time.now.to_i, withscores: true) +
          Redis.current.zrangebyscore(user_anon_views_key, since, Time.now.to_i, withscores: true)
      Hash[*all_visitors.flatten].map do |viewer_id, timestamp|
        visitor_data(nil, nil, nil, 0, viewer_id, timestamp, identify_visitor(viewer_id))
      end
    end

    def visitors(since = 0)
      detailed_visitors = self.detailed_visitors
      first_detailed_visit = detailed_visitors.last.nil? ? updated_at : detailed_visitors.first[:visited_at]
      self.detailed_visitors(since) + simple_visitors(since == 0 ? first_detailed_visit.to_i : since)
    end

    def aggregate_visitors(since = 0)
      aggregate = {}
      visitors(since).map do |visitor|
        user_id = visitor[:user_id].to_i
        aggregate[user_id] ||= visitor
        aggregate[user_id].merge!(visitor) do |key, old, new|
          case key
          when :time_spent
            old.to_i + new.to_i
          when :visited_at
            [old.to_i, new.to_i].max
          when :furthest_scrolled
            SECTIONS[[SECTIONS.index(old) || 0, SECTIONS.index(new) || 0].max]
          else
            old.nil? ? new : old
          end
        end
        aggregate[user_id][:visits] ||= 0
        aggregate[user_id][:visits] += 1

      end
      aggregate.values.sort { |a, b| b[:visited_at] <=> a[:visited_at] }
    end

    def sections_up_to(furthest)
      SECTIONS.slice(0, SECTIONS.index(furthest))
    end

    def number_of_completed_sections(*excluded_sections)
      completed_sections = 0

      sections = (SECTIONS - excluded_sections).map do |section|
        "has_#{section.gsub(/-/, '_')}?"
      end
      sections.each do |section_complete|
        completed_sections += 1 if self.respond_to?(section_complete) &&
            public_send(section_complete)
      end
      completed_sections
    end

    private
      def some_crappy_method(hash_string_to_parse)
        # This code is bad and Mike should feel bad.
        JSON.parse('{' + hash_string_to_parse.gsub(/^{|}$/, '').split(', ')
        .map { |pair| pair.split('=>') }
        .map { |k, v| [k.gsub(/^:(\w*)/, '"\1"'), v == 'nil' ? 'null' : v].join(': ') }.join(', ') + '}')
      end
  end
end
