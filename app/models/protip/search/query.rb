class Query < SearchModule::Search::Query
  def default_query
    "flagged:false"
  end
end