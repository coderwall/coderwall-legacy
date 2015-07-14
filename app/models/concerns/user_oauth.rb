module UserOauth
  extend ActiveSupport::Concern

  def apply_oauth(oauth)
    case oauth[:provider]
      when 'github'
        self.github           = oauth[:info][:nickname]
        self.github_id        = oauth[:uid]
        self.github_token     = oauth[:credentials][:token]
        self.blog             = oauth[:info][:urls][:Blog] if oauth[:info][:urls] && self.blog.blank?
        self.joined_github_on = extract_joined_on(oauth) if self.joined_github_on.blank?
      when 'linkedin'
        self.linkedin_id         = oauth[:uid]
        self.linkedin_public_url = oauth[:info][:urls][:public_profile] if oauth[:info][:urls]
        self.linkedin_token      = oauth[:credentials][:token]
        self.linkedin_secret     = oauth[:credentials][:secret]
      when 'twitter'
        self.twitter           = oauth[:info][:nickname]
        self.twitter_id        = oauth[:uid]
        self.twitter_token     = oauth[:credentials][:token]
        self.twitter_secret    = oauth[:credentials][:secret]
        self.about             = extract_from_oauth_extras(:description, oauth) if self.about.blank?
      when 'developer'
        logger.debug "Using the Developer Strategy for OmniAuth"
        logger.ap oauth, :debug
      else
        raise "Unexpected provider: #{oauth[:provider]}"
    end
  end

  def extract_joined_on(oauth)
    val = extract_from_oauth_extras(:created_at, oauth)
    return Date.parse(val) if val
  end

  def extract_from_oauth_extras(field, oauth)
    oauth[:extra][:raw_info][field] if oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][field]
  end

  module ClassMethods
    def for_omniauth(auth)
      if user = find_with_oauth(auth)
        user.apply_oauth(auth)
        user.save! if user.changed?
      else
        user = new(
            name: auth[:info][:name],
            email: auth[:info][:email],
            backup_email: auth[:info][:email],
            location: location_from(auth))
        #FIXME VCR raise an error when we try to download the image
        avatar_url = avatar_url_for(auth)
        user.avatar.download! avatar_url if avatar_url.present? && !Rails.env.test?
        user.apply_oauth(auth)
        user.username = auth[:info][:nickname]
      end
      user
    end

    def find_with_oauth(oauth)
      case oauth[:provider]
        when 'github'
          (oauth[:uid] ? find_by_github_id(oauth[:uid]) : find_by_github(oauth[:info][:nickname]))
        when 'linkedin'
          find_by_linkedin_id(oauth[:uid])
        when 'twitter'
          find_by_twitter_id(oauth[:uid])
        else
          fail 'Developer Strategy must not be used in production.' if Rails.env.production?
          find_by_email(oauth[:uid])
      end
    end

    def location_from(oauth)
      if oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][:location]
        (oauth[:extra][:raw_info][:location].is_a?(Hash) && oauth[:extra][:raw_info][:location][:name]) || oauth[:extra][:raw_info][:location]
      elsif oauth[:info]
        oauth[:info][:location]
      end
    end

    def avatar_url_for(oauth)
      if oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][:gravatar_id]
        "https://secure.gravatar.com/avatar/#{oauth[:extra][:raw_info][:gravatar_id]}"
      elsif oauth[:info]
        if oauth['provider'] == 'twitter'
          oauth[:extra][:raw_info][:profile_image_url_https]
        else
          oauth[:info][:image]
        end
      end
    end

  end
end
