puts "Removing XML parsing due to security vulernability. Upgrade to rails ASAP"
# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML) 