module Publisher
  def agent
    @@pubnub ||= Pubnub.new(
        ENV['PUBNUB_PUBLISH_KEY'],
        ENV['PUBNUB_SUBSCRIBE_KEY'],
        ENV['PUBNUB_SECRET_KEY'],
        "", ## CIPHER_KEY (Cipher key is Optional)
        ssl_on = false
    )
    @@pubnub
  end

  def publish(channel, message)
    agent.publish({'channel' => channel, 'message' => message}) if agent_active?
  end

  def agent_active?
    @@agent_active ||= !ENV['PUBNUB_PUBLISH_KEY'].blank? && !ENV['PUBNUB_SUBSCRIBE_KEY'].blank? && !ENV['PUBNUB_SECRET_KEY'].blank?
  end

end
