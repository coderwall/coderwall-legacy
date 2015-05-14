class ProviderUserLookupService
  def initialize(provider, username)
    @provider = provider
    @username = username
  end

  def lookup_user
    if valid_provider? && valid_username?
      User.where(@provider.to_sym => @username).first
    else
      nil
    end
  end

  private

  def valid_provider?
    @provider.present? && [:twitter, :github, :linkedin].include?(@provider.to_sym)
  end

  def valid_username?
    @username.present?
  end
end
