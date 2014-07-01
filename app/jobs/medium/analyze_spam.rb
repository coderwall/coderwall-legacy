class AnalyzeSpam < Struct.new(:spammable)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform
    spammable.create_spam_report if spammable.spam?
  end
end
