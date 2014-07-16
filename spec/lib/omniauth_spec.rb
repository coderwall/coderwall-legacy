require 'spec_helper'

RSpec.describe 'omniauth configuration' do
  let(:app) { lambda { |env| [404, {}, ['Awesome']] } }
  let(:strategy) { ExampleStrategy.new(app, @options || {}) }


  it 'should log exception to honeybadger API when auth fails', :skip  do
    expect(Honeybadger).to receive(:notify_or_ignore)

    @options = {failure: :forced_fail}
    strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => '/awesome'}))
  end
end
