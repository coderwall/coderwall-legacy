require 'spec_helper'

RSpec.describe BadgeBase, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  it 'should check to see if it needs to award users' do
    stub_request(:get, 'http://octocoder.heroku.com/rails/rails/mdeiters').
      to_return(body: '{}')
    allow(Octopussy).to receive(:new) do |*_args|
      octopussy_mock = double('Octopussy')
      expect(octopussy_mock).to receive(:valid?).and_return(true)
      expect(octopussy_mock).to receive(:award?).and_return(false)
      octopussy_mock
    end
    BadgeBase.award!(user)
  end

  it 'allows sub classes to have their own description' do
    foo = Class.new(BadgeBase) do
      describe 'Foo', description: 'Foo', image_name: 'foo.png'
    end

    bar = Class.new(foo) do
      describe 'Bar', description: 'Bar', image_name: 'bar.png'
    end

    expect(foo.display_name).to eq('Foo')
    expect(foo.description).to eq('Foo')
    expect(foo.image_name).to eq('foo.png')

    expect(bar.display_name).to eq('Bar')
    expect(bar.description).to eq('Bar')
    expect(bar.image_name).to eq('bar.png')
  end

end
