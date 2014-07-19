module SearchModule
  module ClassMethods
    def rebuild_index(name = nil)
      raise 'Unable to rebuild search index in production because it is disabled by Bonsai' if Rails.env.staging? || Rails.env.production?
      klass = self
      Tire.index name || self.index_name || self.class.name do
        delete
        create
        klass.find_in_batches { |batch| import batch }
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  class Search
    def initialize(context, query=nil, scope=nil, sort=nil, facet=nil, options={})
      @context = context
      @query = query
      @scope = scope
      @sort = sort
      @facet = facet
      @options = failover_strategy.merge(options || {})
    end

    def execute
      query_criteria, filter_criteria, sort_criteria, facets, context = [@query, @scope, @sort, @facet, @context]

      @context.tire.search(@options) do
        query do
          signature = query_criteria.to_tire
          method = signature.shift
          self.send(method, *signature)
        end unless query_criteria.nil? || query_criteria.to_tire.blank?

        filter_criteria.to_tire.each do |fltr|
          filter *fltr
        end unless filter_criteria.nil?

        sort do
          sort_criteria.to_tire.each do |k|
            by k
          end
        end unless sort_criteria.nil?

        ap facets if ENV['DEBUG']
        ap facets.to_tire unless facets.nil?  if ENV['DEBUG']
        # Eval ? Really ?
        eval(facets.to_tire) unless facets.nil?

        puts("[search](#{context.to_s}):" + JSON.pretty_generate(to_hash)) if ENV['DEBUG']
      end
    rescue Tire::Search::SearchRequestFailed, Errno::ECONNREFUSED
      if @options[:failover].nil?
        raise
      else
        @options[:failover].limit(@options[:per_page] || 18).offset(((@options[:page] || 1)-1) * (@options[:per_page] || 19))
      end
    end

    def sort_criteria
      @sort
    end

    def failover_strategy
      { failover: @context.order('created_at DESC') }
    end

    class Scope
      def initialize(domain, object)
        @domain = domain
        @object = object
        @filter = to_hash
      end

      def to_tire
        @filter
      end

      def to_hash
        {}
      end

      def <<(other)
        @filter.deep_merge(other.to_tire)
        self
      end
    end

    class Sort
      def initialize(fields, direction = 'desc')
        @fields = fields.is_a?(Array) ? fields.map(&:to_s) : [fields.to_s]
        @direction = direction
      end

      def to_tire
        @fields.map do |field|
          {field => {order: @direction}}
        end
      end

      alias_method :to_s, :to_tire
    end

    class Query
      def default_query;
        '';
      end

      def initialize(query_string, default_operator = 'AND', default_query_string = default_query)
        @query_string = default_query_string + ' ' + query_string
        @default_operator = default_operator
      end

      def to_tire
        [:string, "#{@query_string}", {default_operator: "#{@default_operator}"}] unless @query_string.blank?
      end
    end

    class Facet
      def initialize(name, type, field, options)
        @name = name
        @type = type
        @field = field
        @global = options.delete(:global) || false
        @options = options
        @facet = to_eval_form
      end

      def to_eval_form
        "facet '#{@name}', :global => #{@global} do \n"\
          "#{@type} :#{@field} #{evaluatable_options} \n"\
          "end"
      end

      def to_tire
        @facet
      end

      def <<(other_facet)
        @facet << "\n" << other_facet.to_eval_form
        self
      end

      private

      def evaluatable_options
        ', ' + @options.join(', ') unless @options.blank?
      end
    end
  end
end
