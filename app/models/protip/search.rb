class Search < SearchModule::Search

  def failover_strategy
    {failover: Protip.order('score DESC')}
  end
end