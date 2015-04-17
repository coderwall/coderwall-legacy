class HawtServiceJob
  include Sidekiq::Worker

  sidekiq_options queue: :protip

  def perform(id, action)
    return '{}' # unless Rails.env.production?
    @protip = Protip.find(id)
    url = URI.parse("#{ENV['PRIVATE_URL']}/api/v1/protips/#{action}.json").to_s
    protip_json = MultiJson.load(protip_hash.to_json)

    Rails.cache.fetch(["hawt_#{action}", @protip], expires: 1.hour) do
      RestClient.post(url, protip_json, accept: :json, content_type: 'application/json')
    end
  end

  private

  def protip_hash
    @protip.as_json(
        methods: [:upvote_velocity, :upvotes, :flagged?, :ever_featured?, :viewed_by_admin?, :networks, :comments, :public_id],
        include: [:user]
    ).merge(token: SecureRandom.uuid, protip_id: @protip.id)
  end


end
