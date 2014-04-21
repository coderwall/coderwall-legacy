if defined?(Footnotes) && (Rails.env.development? || Rails.env.live?)
  Footnotes.run!
  # ... other init code
end
