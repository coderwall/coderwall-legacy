class AnalyzeSpam < Struct.new(:spammable)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform

    spammable.symbolize_keys!
    thing_to_analyze = spammable[:klass].classify.constantize.find(spammable[:id])

    if thing_to_analyze.spam?
      thing_to_analyze.create_spam_report
    end
  end
end
