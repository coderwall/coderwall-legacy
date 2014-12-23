RSpec.describe OpportunitiesController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get('/teams/12345/opportunities/new')).to route_to(controller: 'opportunities', action: 'new', team_id: '12345')
    end

  end
end
