class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment
  include Rakismet::Model

  belongs_to :commentable, polymorphic: true
  has_many :likes, as: :likable, dependent: :destroy
  has_one :spam_report, as: :spammable
  after_create :generate_event
  after_create :analyze_spam
  after_save :commented_callback

  default_scope order: 'likes_cache DESC, created_at ASC'

  belongs_to :user, autosave: true

  alias_method :author, :user
  alias_attribute :body, :comment

  rakismet_attrs  author: proc { self.user.name },
    author_email: proc { self.user.email },
    content: :comment,
    blog: ENV['AKISMET_URL'],
    user_ip: proc { self.user.last_ip },
    user_agent: proc { self.user.last_ua }

  validates :comment, length: { minimum: 2 }

  def self.latest_comments_as_strings(count=5)
    Comment.unscoped.order("created_at DESC").limit(count).collect do |comment|
      "#{comment.comment} - http://coderwall.com/p/#{comment.commentable.try(:public_id)}"
    end
  end

  def commented_callback
    commentable.try(:commented)
  end

  def like_by(user)
    unless self.liked_by?(user) or user.id == self.author_id
      self.likes.create!(user: user, value: user.score)
      generate_event(liker: user.username)
    end
  end

  def liked(how_much=nil)
    commented_callback unless how_much.nil?
  end

  def liked_by?(user)
    likes.where(user_id: user.id).any?
  end

  def authored_by?(user)
    author.id == user.id
  end

  def author_id
    user_id
  end

  def mentions
    User.where(username: username_mentions)
  end

  def username_mentions
    self.body.scan(/@([a-z0-9_]+)/).flatten
  end

  def mentioned?(username)
    username_mentions.include? username
  end

  def to_commentable_public_hash
    self.commentable.try(:to_public_hash).merge(
      {
        comments: self.commentable.comments.count,
        likes:    likes.count,
      }
    )
  end

  def commenting_on_own?
    self.author_id == self.commentable.try(:user_id)
  end

  private

  def generate_event(options={})
    event_type = event_type(options)
    data       = to_event_hash(options)
    GenerateEventJob.perform_async(event_type, event_audience(event_type), data, 1.minute)

    if event_type == :new_comment
      NotifierMailer.new_comment(self.commentable.try(:user).try(:username), self.author.username, self.id).deliver unless commenting_on_own?

      if (mentioned_users = self.mentions).any?
        GenerateEventJob.perform_async(:comment_reply, Audience.users(mentioned_users.map(&:id)), data, 1.minute)

        mentioned_users.each do |mention|
          NotifierMailer.comment_reply(mention.username, self.author.username, self.id).deliver
        end
      end
    end
  end

  def to_event_hash(options={})
    event_hash              = to_commentable_public_hash.merge!({ user: { username: user && user.username }, body: {} })
    event_hash[:created_at] = event_hash[:created_at].to_i

    unless options[:liker].nil?
      event_hash[:user][:username] = options[:liker]
      event_hash[:liker]           = options[:liker]
    end
    event_hash
  end

  def event_audience(event_type, options ={})
    case event_type
    when :new_comment
      audience = Audience.user(self.commentable.try(:user_id))
    else
      audience = Audience.user(self.author_id)
    end
    audience
  end

  def event_type(options={})
    if options[:liker]
      :comment_like
    else
      :new_comment
    end
  end

  def analyze_spam
    AnalyzeSpamJob.perform_async({ id: id, klass: self.class.name })
  end
end

# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  title             :string(50)       default("")
#  comment           :text             default("")
#  commentable_id    :integer
#  commentable_type  :string(255)
#  user_id           :integer
#  likes_cache       :integer          default(0)
#  likes_value_cache :integer          default(0)
#  created_at        :datetime
#  updated_at        :datetime
#  likes_count       :integer          default(0)
#
