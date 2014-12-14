RSpec.describe ProcessLikeJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProcessLikeJob.get_sidekiq_options['queue']).to eql :user
    end
  end

  describe 'processing' do
    let(:user) { Fabricate(:user, tracking_code: 'fake_tracking_code') }
    let(:protip) { Fabricate(:protip) }

    it 'associates the zombie like to the correct user' do
      zombie_like = Fabricate(:like, likable: protip,
        tracking_code: user.tracking_code)

      ProcessLikeJob.new.perform('associate_to_user', zombie_like.id)

      zombie_like.reload

      expect(zombie_like.user_id).to eql user.id
    end

    it 'destroys like that are invalid' do
      invalid_like = Like.new(value: 1, tracking_code: user.tracking_code)
      invalid_like.save(validate: false)

      ProcessLikeJob.new.perform('associate_to_user', invalid_like.id)

      expect(Like.where(id: invalid_like.id)).not_to exist
    end

    it 'destroys likes that are non-unique' do
      original_like = Fabricate(:like, user: user, likable: protip)

      duplicate_like = Fabricate(:like, likable: protip,
        tracking_code: user.tracking_code)

      ProcessLikeJob.new.perform('associate_to_user', duplicate_like.id)

      expect(Like.where(id: duplicate_like.id)).not_to exist
    end

    it 'destroys likes if no user with the tracking code exists' do
      unassociatable_like = Fabricate(:like, likable: protip,
        tracking_code: 'unassociatable_tracking_code')

      ProcessLikeJob.new.perform('associate_to_user', unassociatable_like.id)

      expect(Like.where(id: unassociatable_like.id)).not_to exist
    end
  end

end
