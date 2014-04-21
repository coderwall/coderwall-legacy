class Award < Struct.new(:badge, :date, :provider, :candidate)
  extend ResqueSupport::Basic
  include Awards

  @queue = 'HIGH'

  def perform
    award(badge.constantize, date, provider, candidate)
  end
end