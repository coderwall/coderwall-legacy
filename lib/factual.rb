module Factual
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_factual(_options = {})
      include Factual::InstanceMethods
    end
  end

  module InstanceMethods
    INTERFACE_METHODS = %w(facts fact_identity, fact_owner, fact_name, fact_date, fact_url, fact_tags fact_meta_data)

    INTERFACE_METHODS.each do |method|
      define_method(method) { fail NotImplementedError.new("You must implement #{method} method") }
    end

    def facts
      @facts ||= default_facts
    end

    def default_facts
      [Fact.new(identity: fact_identity, owner: fact_owner, name: fact_name, relevant_on: fact_date,
                url: fact_url, tags: fact_tags, metadata: fact_meta_data)]
    end

    def update_facts!
      facts.each do |fact|
        Fact.create_or_update!(fact)
      end
    end
  end
end
