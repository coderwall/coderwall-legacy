require 'importers'

namespace :protips do

  def progressbar(max)
    @progressbar ||= ProgressBar.create(max)
  end

  # PRODUCTION: RUNS DAILY
  task recalculate_scores: :environment do
    Protip.where('created_at > ?', 25.hours.ago).where(upvotes_value_cache: nil).each do |protip|
      ProcessProtip.perform_async(:recalculate_score, protip.id)
    end
  end

  task recalculate_all_scores: :environment do
    total = Protip.count
    Protip.order('created_at DESC').select(:id).find_each(batch_size: 1000) do |protip|
      progressbar(title: "Protips", format: '%a |%b %i| %p%% %t', total: total).increment
      ProcessProtip.perform_async(:recalculate_score, protip.id)
    end
  end

  task import_unindexed_protips: :environment do
    Protip.where('created_at > ?', 25.hours.ago).find_each(batch_size: 1000) do |protip|
      unless Protip.search("public_id:#{protip.public_id}").any?
        ProcessProtip.perform_async(:resave, protip.id)
      end
    end
  end

  task cache_scores: :environment do
    Protip.find_each(batch_size: 1000) do |protip|
      ProcessProtip.perform_async(:cache_score, protip.id)
    end
  end

  namespace :seed do
    task github_follows: :environment do
      User.find_each(batch_size: 1000) do |user|
        ImportProtip.perform_async(:github_follows, user.username)
      end
    end

    task slideshare: :environment do
      slideshare_facts.each do |fact|
        ImportProtip.perform_async(:slideshare, fact.id)
      end
    end

    task subscriptions: :environment do
      User.find_each(batch_size: 1000) do |user|
        ImportProtip.perform_async(:subscriptions, user.username)
      end
    end
  end

  namespace :comments do
    task send_emails: :environment do
      Comment.find_each do |comment|
        Notifier.new_comment(comment.commentable.try(:user).try(:username), comment.author.username, comment.id).deliver

        comment.mentions.each do |mention|
          Notifier.comment_reply(mention.username, self.author.username, self.id).deliver
        end
      end
    end
  end
end

def slideshare_facts
  (Fact.where('tags LIKE ?', '% slideshare%')).uniq
end
