require 'vcr_helper'

RSpec.describe Protip, type: :model do

  describe 'indexing linked content' do
    it 'indexes page'
  end

  describe 'creating and validating article protips' do
    it 'should create a valid protip' do
      user = Fabricate(:user)
      protip = Fabricate(:protip, user: user)
      protip.save!
      expect(protip.title).not_to be_nil
      expect(protip.body).not_to be_nil
      expect(protip.tags.count).to eq(3)
      protip.topics =~ %w(Javascript CoffeeScript)
      protip.users =~ [user.username]
      expect(protip.public_id.size).to eq(6)
      expect(protip).to be_article
    end
  end

  describe 'creating and validating link protips' do
    it 'should create a valid link protip' do
      title = 'A link'
      link = 'http://www.ruby-doc.org/core/classes/Object.html#M001057'
      protip = Fabricate(:protip, body: link, title: title, user: Fabricate(:user))
      protip.save!
      expect(protip.title).to eq(title)
      expect(protip.body).not_to be_nil
      expect(protip).to be_link
      expect(protip).to be_only_link
      expect(protip.images.count).to eq(0)
      expect(protip.links.count).to eq(1)
      expect(protip.links.first).to eq(link)
      protip.protip_links.count == 1
    end

    it 'should indicate an image protip as not being treated as link' do
      link = '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)'
      protip = Fabricate(:protip, body: link, title: 'not a link', user: Fabricate(:user))
      expect(protip).not_to be_link
      expect(protip).not_to be_only_link
      expect(protip.images.count).to eq(1)
      expect(protip.has_featured_image?).to eq(true)
      expect(protip.links.count).to eq(1)
      expect(protip.protip_links.size).to eq(1)
      expect(protip.protip_links.first.kind.to_sym).to eq(:jpg)
    end
  end

  describe 'searching protip', search: true do
    before(:each) do
      Protip.rebuild_index
    end

    it 'is searchable by title' do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      expect(Protip.search('this content').results.first.title).to eq(protip.title)
    end

    it 'should be an and query' do
      protip1 = Fabricate(:protip, body: 'thing one', title: "content #{r = rand(100)}", user: Fabricate(:user))
      protip1 = Fabricate(:protip, body: 'thing two', title: "content #{r = rand(100)}", user: Fabricate(:user))
      expect(Protip.search('one two').results.size).to eq(0)
    end

    it 'is not searchable if deleted' do
      protip = Fabricate(:protip, title: "I don't exist'", user: Fabricate(:user))
      expect(Protip.search("I don't exist").results.first.title).to eq(protip.title)
      protip.destroy
      expect(Protip.search("I don't exist").results.count).to eq(0)
    end

    it 'is reindexed if username or team change' do
      pending "Not implemented yet"
      team = Fabricate(:team, name: 'first-team')
      user = Fabricate(:user, username: 'initial-username')
      team.add_member(user)
      protip = Fabricate(:protip, body: 'protip by user on team', title: "content #{rand(100)}", user: user)
      user.reload
      expect(Protip.search('team.name:first-team').results.first.title).to eq(protip.title)
      team2 = Fabricate(:team, name: 'second-team')
      team.remove_member(user)
      user.reload
      team2.add_member(user)
      user.reload
      expect(Protip.search('team.name:first-team').results.count).to eq(0)
      expect(Protip.search('team.name:second-team').results.first.title).to eq(protip.title)
      expect(Protip.search("author:#{user.username}").results.first.title).to eq(protip.title)
      user.username = 'second-username'
      user.save!
      expect(Protip.search('author:initial-username').results.count).to eq(0)
      expect(Protip.search("author:#{user.username}").results.first.title).to eq(protip.title)
      user.github = 'something'
      expect(user.save).not_to receive(:refresh_index)
    end
  end

  describe 'tagging protip' do
    it 'should sanitize tags into normalized form' do
      protip = Fabricate(:protip, topic_list: %w(Javascript CoffeeScript), user: Fabricate(:user))
      protip.save!
      expect(protip.topic_list).to match_array(%w(javascript coffeescript))
      expect(protip.topics.count).to eq(2)
    end

    it 'should sanitize empty tag' do
      protip = Fabricate(:protip, topic_list: 'Javascript, ', user: Fabricate(:user))
      protip.save!
      expect(protip.topic_list).to match_array(['javascript'])
      expect(protip.topics.count).to eq(1)
    end

    it 'should remove duplicate tags' do
      protip = Fabricate(:protip, topic_list: %w(github github Github GitHub), user: Fabricate(:user))
      protip.save!
      expect(protip.topic_list).to eq(['github'])
      expect(protip.topics.count).to eq(1)
    end

    it 'should accept tags separated by spaces only' do
      protip = Fabricate(:protip, topic_list: 'ruby python heroku', user: Fabricate(:user))
      protip.save!
      expect(protip.topic_list).to eq(%w(ruby python heroku))
      expect(protip.topics.count).to eq(3)
    end

    it '#topic_ids should return ids of topics only' do
      protip = Fabricate(:protip, topic_list: 'ruby python', user: Fabricate(:user))
      protip.save!
      ruby_id = Tag.find_by_name("ruby").id
      python_id = Tag.find_by_name("python").id
      expect(protip.topic_ids).to match_array([ruby_id, python_id])
    end
  end

  describe 'linking and featuring an image' do
    it 'should indicate when the protip is only a link' do
      protip = Fabricate(:protip, body: 'http://www.google.com', user: Fabricate(:user))
      expect(protip).to be_link

      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      expect(protip).not_to be_only_link
    end

    it 'should indicate when the protip is only a link if it is followed by little content' do
      protip = Fabricate(:protip, body: 'http://www.google.com go check it out!', user: Fabricate(:user))
      expect(protip).to be_only_link
    end

    it 'should indicate when the protip starts with an image' do
      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      expect(protip.has_featured_image?).to eq(true)
    end

    it 'should indicate when the protip starts with an image' do
      protip = Fabricate(:protip, body: '![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      expect(protip.featured_image).to eq('https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG')
    end

    it 'should have a featured_image when the protip has some content before image' do
      protip = Fabricate(:protip, body: 'some text here ![Picture](https://coderwall-assets-0.s3.amazonaws.com/development/picture/file/51/photo.JPG)', user: Fabricate(:user))
      expect(protip.featured_image).not_to be_nil
    end
  end

  describe 'protip wrapper' do
    let(:protip) do
      Fabricate(:protip, user: Fabricate(:user))
    end

    it 'provides a consistence api to a protip' do
      wrapper = Protip::SearchWrapper.new(protip)

      expect(wrapper.user.username).to eq(protip.user.username)
      expect(wrapper.user.profile_url).to eq(protip.user.avatar_url)
      expect(wrapper.upvotes).to eq(protip.upvotes)
      expect(wrapper.topics).to eq(protip.topic_list)
      expect(wrapper.only_link?).to eq(protip.only_link?)
      expect(wrapper.link).to eq(protip.link)
      expect(wrapper.title).to eq(protip.title)
      expect(wrapper.to_s).to eq(protip.public_id)
      expect(wrapper.public_id).to eq(protip.public_id)
    end

    it 'handles link only protips' do
      Protip.rebuild_index
      link_protip = Fabricate(:protip, body: 'http://google.com', user: Fabricate(:user))
      result = Protip.search(link_protip.title).results.first
      wrapper = Protip::SearchWrapper.new(result)
      expect(wrapper.only_link?).to eq(link_protip.only_link?)
      expect(wrapper.link).to eq(link_protip.link)
    end

    it 'provides a consistence api to a protip search result' do
      Protip.rebuild_index
      result = Protip.search(protip.title).results.first
      wrapper = Protip::SearchWrapper.new(result)

      expect(wrapper.user.username).to eq(protip.user.username)
      expect(wrapper.user.profile_url).to eq(protip.user.avatar_url)
      expect(wrapper.upvotes).to eq(protip.upvotes)
      expect(wrapper.topics).to match_array(protip.topic_list)
      expect(wrapper.only_link?).to eq(protip.only_link?)
      expect(wrapper.link).to eq(protip.link)
      expect(wrapper.title).to eq(protip.title)
      expect(wrapper.to_s).to eq(protip.public_id)
      expect(wrapper.public_id).to eq(protip.public_id)
      expect(wrapper.class.model_name).to eq(Protip.model_name)
    end
  end

  describe 'Admin upvoted protips' do
    before(:all) do
      @user = Fabricate(:user)
      @author = Fabricate(:user)
      @author.score_cache = 5
      @user.admin = true
      @user.score_cache = 2
      @protip = Fabricate(:protip, user: @author, body: 'http://www.yahoo.com')
      @initial_score = @protip.score
      @protip.upvote_by(@user, @user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
    end

    it 'should not be featured', skip: true do
      pending

      expect(@protip).not_to be_featured
    end

    it 'should be liked', skip: true do
      pending

      expect(@protip.likes.count).to eq(1)
      expect(@protip.likes.first.user_id).to eq(@user.id)
      expect(@protip.likes.first.value).to eq(@user.like_value)
    end
  end

  describe 'upvotes' do
    let(:protip) { Fabricate(:protip) }
    let(:user) { Fabricate(:user) { score_cache 5 } }

    it 'should upvote by right amount' do
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.reload
      expect(protip.upvotes).to eq(1)
      expect(protip.upvotes_value).to be_within(0.1).of(5)
      expect(protip.upvoters_ids).to eq([user.id])
    end

    it 'should upvote only once per user' do
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.reload
      expect(protip.upvotes).to eq(1)
      expect(protip.likes.count).to eq(1)
    end

    it 'should weigh team member upvotes less' do
      protip.author.team = Fabricate(:team)
      protip.author.save
      team_member = Fabricate(:user, team: protip.author.team)
      team_member.score_cache = 5
      protip.upvote_by(team_member, team_member.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.reload
      expect(protip.upvotes_value).to eq(2)
      non_team_member = Fabricate(:user, team: Fabricate(:team))
      non_team_member.score_cache = 5
      protip.upvote_by(non_team_member, non_team_member.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      protip.reload
      expect(protip.upvotes).to eq(2)
      expect(protip.upvotes_value).to eq(7)
    end
  end

  describe 'scoring' do
    let(:first_protip) { Fabricate(:protip, body: 'some text') }
    let(:second_protip) { Timecop.travel(1.minute.from_now) { Fabricate(:protip, body: 'some text') } }

    let(:user) { Fabricate(:user, score_cache: 2, tracking_code: 'ghi') }

    it 'should have second protip with higher score than first' do
      expect(second_protip.score).to be > first_protip.score
    end

    it 'calculated score should be same as score' do
      expect(first_protip.calculated_score).to eq(first_protip.score)
    end

    it 'upvoted protip should have higher score than unupvoted protip created around same time' do
      twin_protip = Fabricate(:protip, created_at: first_protip.created_at + 1.second, user: Fabricate(:user))
      initial_score = twin_protip.score
      twin_protip.upvote_by(user, user.tracking_code, Protip::DEFAULT_IP_ADDRESS)
      expect(twin_protip.calculated_score).to be > initial_score
    end
  end

  context 'counter_cache' do
    describe 'like_'
  end
end
