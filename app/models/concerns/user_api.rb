module UserApi
  extend ActiveSupport::Concern

  def api_key
    read_attribute(:api_key) || generate_api_key!
  end

  def generate_api_key!
    begin
      key = SecureRandom.hex(8)
    end while User.where(api_key: key).exists?
    update_attribute(:api_key, key)
    key
  end
end
