if Rails.env.production?
  Rails.application.config.middleware.swap(ActionDispatch::Static, Rack::Zippy::AssetServer)
end
