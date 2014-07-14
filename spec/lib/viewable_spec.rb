require 'spec_helper'
require 'viewable'

class Dummy
  include Viewable
  def id
    1
  end
end

describe Viewable do
  let(:subject) { Dummy.new}
  let(:viewer) { Fabricate(:user) }

  it 'is viewable' do
    subject.viewed_by(viewer)
    expect(subject.viewers).to include viewer
  end

  it 'increments impressions'  do
    expect{subject.viewed_by(viewer)}.to change{subject.impressions}.by(1)
  end

  it 'keeps track of total views' do
    expect{subject.viewed_by(viewer)}.to change {subject.total_views}.by(1)
  end

  it 'can tell if subject was viewed by a user' do
    subject.viewed_by(viewer)
    expect(subject.viewed_by_since?(viewer.id)).to be true
  end

  context 'custom time ago' do
    before do
      @some_time_ago = Time.now - 101
      @less_time_ago = Time.now.to_i - 100
      allow(Time).to receive(:now).and_return(@some_time_ago)
    end

    it 'does not include the viewer from before our ask time' do
      subject.viewed_by(viewer)
      expect(subject.viewers(@less_time_ago)).to_not include(viewer)
    end

    it 'does not count views from before our ask time' do
      expect{subject.viewed_by(viewer)}.to_not change {subject.total_views(@less_time_ago)}
    end

    it 'does not return true if view was before our ask time' do
      subject.viewed_by(viewer)
      expect(subject.viewed_by_since?(viewer.id, @less_time_ago)).to be false
    end

  end

end
