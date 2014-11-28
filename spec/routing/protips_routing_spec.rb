RSpec.describe ProtipsController, type: :routing do
  describe 'routing' do

    it 'routes to #topic' do
      expect(get('/p/t')).to route_to('networks#tag')
    end

    it 'routes to #new' do
      expect(get('/p/new')).to route_to('protips#new')
    end

    it 'routes to #show' do
      expect(get('/p/hazc5q')).to route_to('protips#show', id: 'hazc5q')
    end

    it 'routes to #edit' do
      expect(get('/p/hazc5q/edit')).to route_to('protips#edit', id: 'hazc5q')
    end

    it 'routes to #create' do
      expect(post('/p')).to route_to('protips#create')
    end

    it 'routes to #update' do
      expect(put('/p/hazc5q')).to route_to('protips#update', id: 'hazc5q')
    end

    it 'route to #index' do
      expect(get '/trending').to route_to(controller: 'protips', action: 'index')
    end

  end
end
