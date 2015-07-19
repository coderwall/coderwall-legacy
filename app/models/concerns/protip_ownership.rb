module ProtipOwnership
  extend ActiveSupport::Concern

  def owned_by?(owner)
    user == owner || owner.admin?
  end
  alias_method :owner?, :owned_by?
end