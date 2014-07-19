class AnalyzeSpam < Struct.new(:spammable)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform

    spammable.symbolize_keys!

    thing_to_analyze = spammable[:klass].classify.constantize.find(spammable[:id])

    if thing_to_analyze.spam?
      puts("#{spammable[:klass]} with id #{spammable[:id]} was spam") if ENV['DEBUG']
      thing_to_analyze.create_spam_report
    else
      puts("#{spammable[:klass]} with id #{spammable[:id]} was NOT spam") if ENV['DEBUG']
    end
  end
end
