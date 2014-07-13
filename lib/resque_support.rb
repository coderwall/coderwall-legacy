require 'resque_scheduler/tasks'

module ResqueSupport
  module Heroku
    def after_perform_heroku(*args)
      ActiveRecord::Base.connection.disconnect!
    end

    def on_failure_heroku(e, *args)
      ActiveRecord::Base.connection.disconnect!
    end
  end

  module Basic
    include Heroku

    def perform(*args)
      self.new(*args).perform
    end

    def enqueue_in(time, *args)
      klass = args.shift
      if Rails.env.development? or Rails.env.test?
        Rails.logger.debug "Resque#enqueue => #{klass}, #{args}"
        klass.new(*args).perform
      else
        Resque.enqueue_in(time, klass, *args)
      end
    end

    def enqueue(*args)
      enqueue_in(0.seconds, *args)
    end
  end

  module ActiveModel
    include Heroku

    def perform(id, method, *args)
      self.find(id).send(method, *args)
    end

    module Async
      def async(method, *args)
        Resque.enqueue self.class, self.id, method, *args
      end
    end

    def self.extended(base_class)
      base_class.send :include, ResqueSupport::ActiveModel::Async
    end
  end
end