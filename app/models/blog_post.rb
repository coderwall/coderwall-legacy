class BlogPost
  extend ActiveModel::Naming

  BLOG_ROOT = Rails.root.join("app", "blog").expand_path

  class PostNotFound < StandardError
  end

  attr_reader :id

  class << self
    def all_public
      all.select(&:public?)
    end

    def all
      Rails.cache.fetch("blog_posts", expires_in: 30.minutes) do
        all_entries.map { |f| to_post(f) }
      end
    end

    def first
      all.first
    end

    def find(id)
      found_post = all_entries.select { |f| id_of(f) == id }.first
      if found_post.nil?
        raise BlogPost::PostNotFound, "Couldn't find post for id #{id}"
      else
        to_post found_post
      end
    end

    private

    def to_post(pathname)
      BlogPost.new id_of(pathname), BLOG_ROOT.join(pathname)
    end

    def all_entries
      BLOG_ROOT.entries.reject do |entry|
        entry.directory? || entry.to_s =~ /^draft/
      end.sort.reverse
    end

    def id_of(pathname)
      pathname.basename.to_s.sub(pathname.extname, "")
    end
  end

  def initialize(id, content)
    @id, @content = id, content
  end

  def public?
    metadata['private'].blank?
  end

  def title
    metadata['title']
  end

  def author
    metadata['author']
  end

  def posted
    DateTime.parse metadata['posted']
  end

  def html
    Kramdown::Document.new(cached_content[2]).to_html.html_safe
  end

  private

  def metadata
    YAML.load(cached_content[1])
  end

  def cached_content
    @cached_content ||= @content.read.split("---")
  end

end
