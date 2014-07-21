Coderwall::Application.configure do
  config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
  config.assets.precompile << 'admin.css'
  config.assets.version = '1.1'
end
