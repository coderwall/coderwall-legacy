class AssignNetworksJob
  include Sidekiq::Worker

  sidekiq_options queue: :network

  def perform(username)
    user = User.find_by_username(username)
    user.skills.map(&:name).each do |skill|
      Network.all_with_tag(skill).each do |network|
        user.join(network)
      end
    end
  end
end
