require 'spec_helper'

describe BadgeBase do
  let(:repo) { Fabricate(:github_repo) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should check to see if it needs to award users' do
    stub_request(:get, 'http://octocoder.heroku.com/rails/rails/mdeiters').to_return(body: '{}')
    Octopussy.stub(:new).and_return do |*args|
      octopussy_mock = double("Octopussy")
      octopussy_mock.should_receive(:valid?).and_return(true)
      octopussy_mock.should_receive(:award?).and_return(false)
      octopussy_mock
    end
    BadgeBase.award!(user)
  end

  it 'allows sub classes to have their own description' do
    foo = Class.new(BadgeBase) do
      describe "Foo", description: "Foo", image_name: 'foo.png'
    end

    bar = Class.new(foo) do
      describe "Bar", description: "Bar", image_name: 'bar.png'
    end

    foo.display_name.should == 'Foo'
    foo.description.should == 'Foo'
    foo.image_name.should == 'foo.png'

    bar.display_name.should == 'Bar'
    bar.description.should == 'Bar'
    bar.image_name.should == 'bar.png'
  end

  class NotaBadge < BadgeBase
    def award?;
      true;
    end

    def reasons;
      ["I don't need a reason"];
    end
  end
end
