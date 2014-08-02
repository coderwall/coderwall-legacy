Coderwall::Application.configure do
  config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
  config.assets.precompile << %w(
    account.js
    accounts.js
    admin.css
    application.css
    application.js
    autosaver.js
    connections.js
    ember/dashboard.js
    ember/teams.js
    premium-admin.js
    premium-teams.css
    premium.js
    product_description.css
    protip.css
    protips-grid.js
    protips.js
    search.js
    settings.js
    teams.js
    tracking.js
    user.js
    username-validation.js
  )

  config.assets.version = '1.1'
end
