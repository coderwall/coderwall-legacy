class SearchResultsWrapper

  def initialize(results=nil, error=nil)
    @results = results
    @error = error
  end

  def results
    @results || []
  end

  def error
    @error
  end

  def errored?
    !@error.nil?
  end

  def empty?
    @results.blank?
  end

  def size
    results.size
  end

  def total
    size
  end

  alias_method :count, :total
  alias_method :failure?, :errored?
end