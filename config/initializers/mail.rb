Coderwall::Application.configure do
  config.action_mailer.smtp_settings = {
      authentication: :plain,
      address: ENV['MAILGUN_SMTP_SERVER'],
      port: ENV['MAILGUN_SMTP_PORT'],
      domain: 'coderwall.com',
      user_name: ENV['MAILGUN_SMTP_LOGIN'],
      password: ENV['MAILGUN_SMTP_PASSWORD']
  }
end