require 'spec_helper'

RSpec.describe BlogPost, type: :model do

  let(:post_markdown) do
    '' "
---
title: Hello World
posted: Mon, 09 Jan 2012 00:27:01 -0800
author: gthreepwood
---
This is a test of the thing. _Markdown_ should work.
" ''
  end

  let(:post) { BlogPost.new('2012-01-09-hello-world', StringIO.new(post_markdown)) }

  describe 'class methods' do
    # Hack.
    before do
      @old_root = BlogPost::BLOG_ROOT
      silence_warnings { BlogPost::BLOG_ROOT = Rails.root.join('spec', 'fixtures', 'blog') }
    end

    after do
      silence_warnings { BlogPost::BLOG_ROOT = @old_root }
    end

    it 'should find a post by its id' do
      post = BlogPost.find('2011-07-22-gaming-the-game')
      expect(post).not_to be_nil
      expect(post.id).to eq('2011-07-22-gaming-the-game')
    end

    it 'should raise PostNotFound if the post does not exist' do
      expect { BlogPost.find('2012-01-09-hello-world') }.to raise_error(BlogPost::PostNotFound)
    end

    it 'should retrieve a list of all posts and skip posts that begin with draft-' do
      posts = BlogPost.all
      expect(posts.map(&:id)).to eq(['2011-07-22-gaming-the-game'])
    end
  end

  describe 'instance methods' do
    it 'should have an id' do
      expect(post.id).to eq('2012-01-09-hello-world')
    end

    it 'should have a title' do
      expect(post.title).to eq('Hello World')
    end

    it 'should have a posted-on date' do
      expect(post.posted).to eq(DateTime.parse('Mon, 09 Jan 2012 00:27:01 -0800'))
    end

    it 'should have an author' do
      expect(post.author).to eq('gthreepwood')
    end

    it "should have html that's been parsed with Markdown" do
      expect(post.html).to match('<p>This is a test of the thing. <em>Markdown</em> should work.</p>')
    end
  end

end
