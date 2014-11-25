class CleanupProtipsAssociateZombieUpvotesJob
  include Sidekiq::Worker

  sidekiq_options queue: :data_cleanup

  def perform
    Like.joins('inner join users on users.tracking_code = likes.tracking_code').
      where('likes.tracking_code is not null').
      where(user_id: nil).
      find_each(batch_size: 100) do |like|
        ProcessLikeJob.perform_async(:associate_to_user, like.id)
      end
  end
end
