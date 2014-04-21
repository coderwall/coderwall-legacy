# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `protips`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`body`**                 | `text`             |
# **`boost_factor`**         | `float`            | `default(1.0)`
# **`created_at`**           | `datetime`         |
# **`created_by`**           | `string(255)`      | `default("self")`
# **`featured`**             | `boolean`          | `default(FALSE)`
# **`featured_at`**          | `datetime`         |
# **`id`**                   | `integer`          | `not null, primary key`
# **`inappropriate`**        | `integer`          | `default(0)`
# **`kind`**                 | `string(255)`      |
# **`public_id`**            | `string(255)`      |
# **`score`**                | `float`            |
# **`title`**                | `string(255)`      |
# **`updated_at`**           | `datetime`         |
# **`upvotes_value_cache`**  | `integer`          |
# **`user_id`**              | `integer`          |
#
# ### Indexes
#
# * `index_protips_on_public_id`:
#     * **`public_id`**
# * `index_protips_on_user_id`:
#     * **`user_id`**
#

describe Protip do

  describe 'indexing linked content' do

    it 'indexes page'
  end

  describe 'creating and validating article protips' do
    it 'should create a valid protip' do
      user = Fabricate(:user)
      protip = Fabricate(:protip, user: user)
      protip.save!
      protip.title.should_not be_nil
      protip.body.should_not be_nil
      protip.tags.count.should == 3
      protip.topics =~ ["Javascript", "CoffeeScript"]
      protip.users =~ [user.username]
      protip.public_id.should have(6).characters
      protip.should be_article
    end
  end

  describe 'creating and validating link protips' do
    it 'should create a valid link protip' do
      title = "A link"
      link = "http://www.ruby-doc.org/core/classes/Object.html#M001057"
      protip = Fabricate(:protip, body: link, title: title, user: Fabricate(:user))
      protip.save!
      protip.title.should == title
      protip.body.should_not be_nil
      protip.should be_link
      protip.should be_only_link
      protip.images.count.should == 0
      protip.links.count.should == 1
      protip.links.first.should == link
      protip.protip_links.count == 1
    end

    it 'should indicate an image protip as not being treated as link' do
      link = '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)';
      protip = Fabricate(:protip, body: link, title: "not a link", user: Fabricate(:user))
      protip.should_not be_link
      protip.should_not be_only_link
      protip.images.count.should == 1
      protip.has_featured_image?.should == true
      protip.links.count.should == 1
      protip.should have(1).protip_links
      protip.protip_links.first.kind.to_sym.should == :jpg
    end
  end

  describe 'searching protip', search: true do
    before(:each) do
      Protip.rebuild_index
    end

    it 'is searchable by title' do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      Protip.search('this content').results.first.title.should == protip.title
    end

    it 'should be an and query' do
      protip1 = Fabricate(:protip, body: 'thing one', title: "content #{r = rand(100)}", user: Fabricate(:user))
      protip1 = Fabricate(:protip, body: 'thing two', title: "content #{r = rand(100)}", user: Fabricate(:user))
      Protip.search('one two').results.size.should == 0
    end

    it 'is not searchable if deleted' do
      protip = Fabricate(:protip, title: "I don't exist'", user: Fabricate(:user))
      Protip.search("I don't exist").results.first.title.should == protip.title
      protip.destroy
      Protip.search("I don't exist").results.count.should == 0
    end

    it 'is reindexed if username or team change' do
      team = Fabricate(:team, name: "first-team")
      user = Fabricate(:user, username: "initial-username")
      team.add_user(user)
      protip = Fabricate(:protip, body: 'protip by user on team', title: "content #{r = rand(100)}", user: user)
      user.reload
      Protip.search("team.name:first-team").results.first.title.should == protip.title
      team2 = Fabricate(:team, name: "second-team")
      team.remove_user(user)
      user.reload
      team2.add_user(user)
      user.reload
      Protip.search("team.name:first-team").results.count.should == 0
      Protip.search("team.name:second-team").results.first.title.should == protip.title
      Protip.search("author:#{user.username}").results.first.title.should == protip.title
      user.username = "second-username"
      user.save!
      Protip.search("author:initial-username").results.count.should == 0
      Protip.search("author:#{user.username}").results.first.title.should == protip.title
      user.github = "something"
      user.save.should_not_receive(:refresh_index)
    end
  end

  describe 'tagging protip' do
    it 'should sanitize tags into normalized form' do
      protip = Fabricate(:protip, topics: ["Javascript", "CoffeeScript"], user: Fabricate(:user))
      protip.save!
      protip.topics.should =~ ["javascript", "coffeescript"]
      protip.topics.count.should == 2
    end

    it 'should sanitize empty tag' do
      protip = Fabricate(:protip, topics: "Javascript, ", user: Fabricate(:user))
      protip.save!
      protip.topics.should =~ ["javascript"]
      protip.topics.count.should == 1
    end

    it 'should remove duplicate tags' do
      protip = Fabricate(:protip, topics: ["github", "github", "Github", "GitHub"], user: Fabricate(:user))
      protip.save!
      protip.topics.should == ["github"]
      protip.topics.count.should == 1
    end

    it 'should accept tags separated by spaces only' do
      protip = Fabricate(:protip, topics: "ruby python heroku", user: Fabricate(:user))
      protip.save!
      protip.topics.should == ["ruby", "python", "heroku"]
      protip.topics.count.should == 3
    end
  end

  describe 'linking and featuring an image' do
    it 'should indicate when the protip is only a link' do
      protip = Fabricate(:protip, body: 'http://www.google.com', user: Fabricate(:user))
      protip.should be_link

      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      protip.should_not be_only_link
    end

    it 'should indicate when the protip is only a link if it is followed by little content' do
      protip = Fabricate(:protip, body: 'http://www.google.com go check it out!', user: Fabricate(:user))
      protip.should be_only_link
    end

    it 'should indicate when the protip starts with an image' do
      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      protip.has_featured_image?.should == true
    end

    it 'should indicate when the protip starts with an image' do
      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      protip.featured_image.should == 'https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG'
    end

    it 'should have a featured_image when the protip has some content before image' do
      protip = Fabricate(:protip, body: 'some text here ![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      protip.featured_image.should_not be_nil
    end
  end

  describe 'protip wrapper' do
    let(:protip) {
      Fabricate(:protip, user: Fabricate(:user))
    }

    it 'provides a consistence api to a protip' do
      wrapper = Protip::SearchWrapper.new(protip)

      wrapper.user.username.should == protip.user.username
      wrapper.user.profile_url.should == protip.user.profile_url
      wrapper.upvotes.should == protip.upvotes
      wrapper.topics.should == protip.topics
      wrapper.only_link?.should == protip.only_link?
      wrapper.link.should == protip.link
      wrapper.title.should == protip.title
      wrapper.to_s.should == protip.public_id
      wrapper.public_id.should == protip.public_id
    end

    it 'handles link only protips' do
      Protip.rebuild_index
      link_protip = Fabricate(:protip, body: 'http://google.com', user: Fabricate(:user))
      result = Protip.search(link_protip.title).results.first
      wrapper = Protip::SearchWrapper.new(result)
      wrapper.only_link?.should == link_protip.only_link?
      wrapper.link.should == link_protip.link
    end

    it 'provides a consistence api to a protip search result' do
      Protip.rebuild_index
      result = Protip.search(protip.title).results.first
      wrapper = Protip::SearchWrapper.new(result)

      wrapper.user.username.should == protip.user.username
      wrapper.user.profile_url.should == protip.user.profile_url
      wrapper.upvotes.should == protip.upvotes
      wrapper.topics.should == protip.topics
      wrapper.only_link?.should == protip.only_link?
      wrapper.link.should == protip.link
      wrapper.title.should == protip.title
      wrapper.to_s.should == protip.public_id
      wrapper.public_id.should == protip.public_id
      wrapper.class.model_name.should == Protip.model_name
    end
  end

  describe "Admin upvoted protips" do
    before(:all) do
      @user = Fabricate(:user)
      @author = Fabricate(:user)
      @author.score_cache = 5
      @user.admin = true
      @user.score_cache = 2
      @protip = Fabricate(:protip, user: @author, body: "http://www.yahoo.com")
      @initial_score = @protip.score
      @protip.upvote_by(@user, @user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
    end

    it 'should not be featured' do
      @protip.should_not be_featured
    end

    it 'should be liked' do
      @protip.likes.count.should == 1
      @protip.likes.first.user_id.should == @user.id
      @protip.likes.first.value.should == @user.like_value
    end
  end

  describe 'upvotes' do
    let(:protip) { Fabricate(:protip, user: Fabricate(:user)) }
    let(:user) {
      u = Fabricate(:user)
      u.score_cache = 5
      u
    }
    it 'should upvote by right amount' do
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvotes.should == 1
      protip.upvotes_value.should be_within(0.1).of(5)
      protip.upvoters_ids.should == [user.id]
    end

    it 'should upvote only once per user' do
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvotes.should == 1
      protip.likes.count.should == 1
    end

    it 'should weigh team member upvotes less' do
      protip.author.team_document_id = "4f271930973bf00004000001"
      protip.author.save
      team_member = Fabricate(:user, team_document_id: protip.author.team_document_id)
      team_member.score_cache = 5
      protip.upvote_by(team_member, team_member.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvotes_value.should == 2
      non_team_member = Fabricate(:user, team_document_id: "4f271930973bf00004000002")
      non_team_member.score_cache = 5
      protip.upvote_by(non_team_member, non_team_member.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvotes.should == 2
      protip.upvotes_value.should == 7
    end
  end

  describe 'scoring' do
    let(:first_protip) { Fabricate(:protip, user: Fabricate(:user), body: 'some text') }
    let(:second_protip) { Timecop.travel(1.minute.from_now) { Fabricate(:protip, user: Fabricate(:user), body: 'some text') } }

    let(:user) {
      u = Fabricate(:user)
      u.score_cache = 2
      u.tracking_code = "ghi"
      u
    }

    it 'should have second protip with higher score than first' do
      second_protip.score.should be > first_protip.score
    end

    it 'calculated score should be same as score' do
      first_protip.calculated_score.should be == first_protip.score
    end

    it 'upvoted protip should have higher score than unupvoted protip created around same time' do
      twin_protip = Fabricate(:protip, created_at: first_protip.created_at + 1.second, user: Fabricate(:user))
      initial_score = twin_protip.score
      twin_protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      twin_protip.calculated_score.should be > initial_score
    end
  end

end
