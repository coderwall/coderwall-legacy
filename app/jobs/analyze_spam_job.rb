class AnalyzeSpamJob
  include Sidekiq::Worker

  sidekiq_options queue: :data_cleanup

  def perform(spammable)
    return if Rails.env.test? || Rails.env.development?
    begin
      thing_to_analyze = spammable['klass'].classify.constantize.find(spammable['id'])

      if thing_to_analyze.spam?
        thing_to_analyze.create_spam_report unless thing_to_analyze.spam_report.present?
      end
    rescue ActiveRecord::RecordNotFound
      return
    end
  end
end
