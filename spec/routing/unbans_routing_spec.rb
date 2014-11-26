# TODO This file should be removed
RSpec.describe UnbansController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post('/users/666/bans')).to route_to(controller: 'bans', action: 'create', user_id: '666')
    end

  end
end
