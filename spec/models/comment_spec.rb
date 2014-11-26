require 'spec_helper'

RSpec.describe Comment, type: :model, skip: true do
  let(:comment) { Fabricate(:comment) }

  describe '#spam_report' do
    subject { super().spam_report }
    it { is_expected.to be_nil }
  end

  context 'counter_cache' do

    it 'should update count' do

      expect(comment.likes_count).to be_zero
      # Random tests
      rand(2..10).times do
        comment.likes.create(user: Fabricate(:user))
      end
      expect(comment.likes_count).to eq(comment.likes.count)
      comment.likes.last.destroy
      expect(comment.likes_count).to eq(comment.likes.count)
    end

  end
end
