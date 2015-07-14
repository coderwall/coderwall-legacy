require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :viewed_by
    expect(user).to respond_to :viewers
    expect(user).to respond_to :total_views
  end

  it 'tracks when a user views a profile' do
    user = Fabricate :user
    viewer = Fabricate :user
    user.viewed_by(viewer)
    expect(user.viewers.first).to eq(viewer)
    expect(user.total_views).to eq(1)
  end

  it 'tracks when a user views a profile' do
    user = Fabricate :user
    user.viewed_by(nil)
    expect(user.total_views).to eq(1)
  end

end
