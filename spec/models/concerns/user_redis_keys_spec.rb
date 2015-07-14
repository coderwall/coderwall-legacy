require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to methods' do
    expect(user).to respond_to :repo_cache_key
    expect(user).to respond_to :daily_cache_key
    expect(user).to respond_to :timeline_key
    expect(user).to respond_to :impressions_key
    expect(user).to respond_to :user_views_key
    expect(user).to respond_to :user_anon_views_key
    expect(user).to respond_to :followed_repo_key
    expect(user).to respond_to :followers_key
    expect(user).to respond_to :bitbucket_identity
    expect(user).to respond_to :speakerdeck_identity
    expect(user).to respond_to :slideshare_identity
    expect(user).to respond_to :github_identity
    expect(user).to respond_to :linkedin_identity
    expect(user).to respond_to :lanyrd_identity
    expect(user).to respond_to :twitter_identity
  end

  it 'should use username as repo_cache_key' do
    expect(user.repo_cache_key).to eq(user.username)
  end

  it 'should use a daily cache key' do
    expect(user.daily_cache_key).to eq("#{user.repo_cache_key}/#{Date.today.to_time.to_i}")
  end

  it 'should return correct timeline namespace' do
    expect(user.timeline_key).to eq("user:#{user.id}:timeline")
  end

  it 'should return correct impression namespace' do
    expect(user.impressions_key).to eq("user:#{user.id}:impressions")
  end

  it 'should return correct view namespace' do
    expect(user.user_views_key).to eq("user:#{user.id}:views")
  end

  it 'should return correct anon view namespace' do
    expect(user.user_anon_views_key).to eq("user:#{user.id}:views:anon")
  end

  it 'should return correct followed repo namespace' do
    expect(user.followed_repo_key).to eq("user:#{user.id}:following:repos")
  end

  it 'should return correct followers namespace' do
    expect(user.followers_key).to eq("user:#{user.id}:followers")
  end

  describe '#bitbucket_identity' do
    it 'return nil if no account is present' do
      expect(user.bitbucket_identity).to be_nil
    end
    it 'return identity if account is present' do
      bitbucket_account = FFaker::Internet.user_name
      user.bitbucket = bitbucket_account
      expect(user.bitbucket_identity).to eq("bitbucket:#{bitbucket_account}")
    end
  end
  describe '#speakerdeck_identity' do
    it 'return nil if no account is present' do
      expect(user.speakerdeck_identity).to be_nil
    end
    it 'return identity if account is present' do
      speakerdeck_account = FFaker::Internet.user_name
      user.speakerdeck = speakerdeck_account
      expect(user.speakerdeck_identity).to eq("speakerdeck:#{speakerdeck_account}")
    end
  end
  describe '#slideshare_identity' do
    it 'return nil if no account is present' do
      expect(user.slideshare_identity).to be_nil
    end
    it 'return identity if account is present' do
      slideshare_account = FFaker::Internet.user_name
      user.slideshare = slideshare_account
      expect(user.slideshare_identity).to eq("slideshare:#{slideshare_account}")
    end
  end

  describe '#github_identity' do
    it 'return nil if no account is present' do
      user.github = nil
      expect(user.github_identity).to be_nil
    end
    it 'return identity if account is present' do
      github_account = FFaker::Internet.user_name
      user.github = github_account
      expect(user.github_identity).to eq("github:#{github_account}")
    end
  end
  describe '#linkedin_identity' do
    it 'return nil if no account is present' do
      expect(user.linkedin_identity).to be_nil
    end
    it 'return identity if account is present' do
      linkedin_token_account = FFaker::Internet.user_name
      linkedin_secret_account = FFaker::Internet.user_name
      user.linkedin_token = linkedin_token_account
      user.linkedin_secret = linkedin_secret_account
      expect(user.linkedin_identity).to eq("linkedin:#{linkedin_token_account}::#{linkedin_secret_account}")
    end
  end
  describe '#lanyrd_identity' do
    it 'return nil if no account is present' do
      user.twitter = nil
      expect(user.lanyrd_identity).to be_nil
    end
    it 'return identity if account is present' do
      twitter_account = FFaker::Internet.user_name
      user.twitter = twitter_account
      expect(user.lanyrd_identity).to eq("lanyrd:#{twitter_account}")
    end
  end
  describe '#twitter_identity' do
    it 'return nil if no account is present' do
      user.twitter = nil
      expect(user.twitter_identity).to be_nil
    end
    it 'return identity if account is present' do
      twitter_account = FFaker::Internet.user_name
      user.twitter = twitter_account
      expect(user.twitter_identity).to eq("twitter:#{twitter_account}")
    end
  end
end
