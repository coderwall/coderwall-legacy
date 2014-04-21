class ProcessLike < Struct.new(:process_type, :like_id)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    like = Like.find(like_id)
    case process_type.to_sym
      when :associate_to_user
        begin
          like.user_id = User.find_by_tracking_code(like.tracking_code)
          like.save
        rescue ActiveRecord::RecordNotUnique
          like.destroy
        end
    end
  end
end