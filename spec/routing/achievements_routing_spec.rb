RSpec.describe AchievementsController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(post('/award')).to route_to(controller: 'achievements', action: 'award')
    end

  end
end
