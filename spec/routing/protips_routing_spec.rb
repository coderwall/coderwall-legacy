RSpec.describe ProtipsController, type: :routing do
  describe 'routing' do
    it 'GET p/:id/:slug routes to #show' do
      expect(get('/p/1234/abcd')).to route_to(controller: 'protips', action: 'show', id: '1234', slug: 'abcd')
    end

    it 'POST p/:id/upvote routes to #upvote' do
      expect(post('/p/abcd/upvote')).to route_to(controller: 'protips', action: 'upvote', id: 'abcd')
    end
  end
end
