require 'vcr_helper'

RSpec.shared_context :github_shared_context do
  let(:coderwall_user) { Fabricate(:user) }
  let(:client) { Coderwall::Github::Client.new(coderwall_user.github_token).client }
  let(:github_username) { 'just3ws' }
end
