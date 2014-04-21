describe BlogPostsController do

  describe 'GET /blog/:id' do
    it 'should retrieve the post for the given id' do
      BlogPost.stub(:find) { double(text: 'Some text') }
      get :show, id: '2011-07-22-gaming-the-game'
      assigns(:blog_post).text.should == 'Some text'
    end
  end

  describe 'GET /blog' do
    it 'should retrieve a list of all posts' do
      BlogPost.stub(:all) { [double(text: 'Some text', public?: true)] }
      get :index
      assigns(:blog_posts).size.should == 1
      assigns(:blog_posts).first.text.should == 'Some text'
    end
  end
end
