class AnalyzeSpam < Struct.new(:spammable)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform

    ap(spammable) unless Rails.env.test?

    spammable.symbolize_keys!

    thing_to_analyze = spammable[:klass].constantize.find(spammable[:id])

    ap(thing_to_analyze) unless Rails.env.test?

    if thing_to_analyze.spam?
      puts("#{spammable[:klass]} with id #{spammable[:id]} was spam") unless Rails.env.test?
      thing_to_analyze.create_spam_report
    else
      puts("#{spammable[:klass]} with id #{spammable[:id]} was NOT spam") unless Rails.env.test?
    end
  end
end
