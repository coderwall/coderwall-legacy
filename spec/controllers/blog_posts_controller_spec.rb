RSpec.describe BlogPostsController, :type => :controller do

  describe 'GET /blog/:id' do
    it 'should retrieve the post for the given id' do
      allow(BlogPost).to receive(:find) { double(text: 'Some text') }
      get :show, id: '2011-07-22-gaming-the-game'
      expect(assigns(:blog_post).text).to eq('Some text')
    end
  end

  describe 'GET /blog' do
    it 'should retrieve a list of all posts' do
      allow(BlogPost).to receive(:all) { [double(text: 'Some text', public?: true)] }
      get :index
      expect(assigns(:blog_posts).size).to eq(1)
      expect(assigns(:blog_posts).first.text).to eq('Some text')
    end
  end
end
