class ProcessLikeJob
  include Sidekiq::Worker

  sidekiq_options queue: :user

  def perform(process_type, like_id)
    like = Like.find(like_id)
    case process_type
      when 'associate_to_user'
        begin
          like.user_id = User.find_by_tracking_code(like.tracking_code)
          like.save!
        rescue ActiveRecord::RecordNotUnique => ex
          ap ex
          like.destroy
        end
    end
  end
end
