RSpec.describe BlogPostsController, type: :routing do
  describe 'routing' do

    it 'does not route to #index' do
      expect(get('/blog')).to_not route_to('blog_posts#index')
    end

    it 'does not route to #show' do
      expect(get('/blog/some-random-slug')).to_not route_to('blog_posts#show', id: 'some-random-slug')
    end
  end
end
