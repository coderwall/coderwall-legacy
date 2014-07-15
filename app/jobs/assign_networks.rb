class AssignNetworks < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    user = User.with_username(username)
    user.skills.map(&:name).each do |skill|
      Network.all_with_tag(skill).each do |network|
        user.join(network)
      end
    end
  end
end
