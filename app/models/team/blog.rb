module Team::Blog
  def blog_posts
    @blog_posts ||= Entry.new(blog_feed).entries
  end

  def has_team_blog?
    blog_feed.present?
  end

  class Entry
    attr_reader :feed

    def initialize(url)
      @feed = Feedjira::Feed.fetch_and_parse(url)
      @valid = true unless @feed.is_a?(Fixnum)
    end

    def valid?
      !!@valid
    end

    def entries
      if valid?
        feed.entries
      else
        []
      end
    end

    delegate :size, :any?, :empty?, to: :entries

    alias_method :count, :size
  end
end