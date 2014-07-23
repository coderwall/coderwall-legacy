if Rails::VERSION::MAJOR < 4
  AbstractController::Callbacks::ClassMethods.class_eval do
    alias_method :before_action, :before_filter
    alias_method :after_action, :after_filter
    alias_method :skip_before_action, :skip_before_filter
  end
else
  Rails.logger.error 'You can delete rails_4.rb initializer, Congratulations for passing to rails 4'
end