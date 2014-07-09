class AnalyzeSpam < Struct.new(:spammable)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform
    ap spammable

    thing_to_analyze = spammable['commentable_type'].constantize.find_by_id(spammable['id'])

    if thing_to_analyze.spam?
      thing_to_analyze.create_spam_report
    end
  end
end
