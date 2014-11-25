class ResizeTiltShiftBannerJob
  include Sidekiq::Worker

  sidekiq_options queue: :user

  def perform(klass, id, column)
    image = klass.constantize.find(id)
    unless image.nil?
      image.send(:"#{column}").resize_to_fit(500, 375)
      image.send(:"#{column}").apply_tilt_shift
      image.save!
    end
  end
end
