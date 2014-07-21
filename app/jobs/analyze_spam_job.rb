class AnalyzeSpamJob
  include Sidekiq::Worker

  sidekiq_options queue: :medium

  def perform(spammable)
    return if Rails.env.test?
    thing_to_analyze = spammable['klass'].classify.constantize.find(spammable['id'])

    if thing_to_analyze.spam?
      thing_to_analyze.create_spam_report
    end
  end
end
