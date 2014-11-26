RSpec.describe UsersController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get('/seuros')).to route_to(controller: 'users', action: 'show', username: 'seuros')
    end

  end
end
