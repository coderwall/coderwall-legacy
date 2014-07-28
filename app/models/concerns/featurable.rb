module Featurable
  extend ActiveSupport::Concern

  included do
    after_save :feature!

    scope :featured, where(featured: true).order('featured_at DESC')
  end

  def hawt_service
    @hawt_service ||= Services::Protips::HawtService.new(self)
  end

  def hawt?
    hawt_service.hawt?
  end

  def feature!
    hawt_service.feature!
  end

  def unfeature!
    hawt_service.unfeature!
  end

  def feature
    self.featured = true
    self.featured_at = Time.now
  end

  def unfeature
    self.featured = false
  end

  def ever_featured?
    !self.featured_at.blank?
  end

  def featured?
    self.featured
  end

  def has_featured_image?
    !featured_image.nil?
  end

  def featured_image
    # match = body.match FEATURED_PHOTO
    # match[1] unless match.nil?
    images.first
  end
end
