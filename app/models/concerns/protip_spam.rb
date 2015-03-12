module ProtipSpam
  extend ActiveSupport::Concern
  included do
    after_create :analyze_spam

    def analyze_spam
      AnalyzeSpamJob.perform_async({ id: id, klass: self.class.name })
    end
  end
end