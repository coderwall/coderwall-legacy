module SpamFilter
  extend ActiveSupport::Concern

  included do
    after_save :analyze_spam
    has_one :spam_report, as: :spammable
    include Rakismet::Model

    rakismet_attrs author: :user_name,
                   author_email: :user_email,
                   content: :body,
                   blog: ENV['AKISMET_URL'],
                   user_ip: :remote_ip,
                   user_agent: :user_agent

    def analyze_spam
      AnalyzeSpamJob.perform_async({ id: id, klass: self.class.name })
    end

  end
end
