RSpec.describe TeamsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get('/team/coderwall')).to route_to(controller: 'teams', action: 'show', slug: 'coderwall')
    end

    it 'routes to #edit with ' do
      expect(get('/team/test-team/edit')).to route_to(controller: 'teams', action: 'edit', slug: 'test-team')
    end

    it 'routes to #edit' do
      expect(get('/team/coderwall/edit')).to route_to(controller: 'teams', action: 'edit', slug: 'coderwall')
    end

    it 'routes to #show with  job id' do
      expect(get('/team/coderwall/666')).to route_to(controller: 'teams', action: 'show', slug: 'coderwall', job_id: '666')
    end
  end
end
