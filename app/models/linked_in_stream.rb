class LinkedInStream < Struct.new(:username)
  KEY    = ENV['LINKEDIN_KEY']
  SECRET = ENV['LINKEDIN_SECRET']

  def facts
    facts = []

    profile.positions.each do |position|
      name     = build_name(position)
      date     = build_start_date(position)
      url      = profile.public_profile_url
      tags     = ['linkedin', 'job']
      metadata = {
        end_date: build_end_date(position),
        summary:  position.summary,
      }
      if position.company && position.company.name
        metadata[:company] = position.company.name
      end
      facts << Fact.append!(position.id.to_s, "linkedin:#{username}", name, date, url, tags, metadata)
    end

    profile.educations.each do |education|
      name     = build_education_name(education)
      date     = build_start_date(education)
      url      = profile.public_profile_url
      tags     = ['linkedin', 'education']
      metadata = {
        end_date: build_end_date(education),
        degree:   education.degree,
        school:   education.school_name
      }
      facts << Fact.append!(education.id.to_s, "linkedin:#{username}", name, date, url, tags, metadata)
    end
    facts
  rescue RestClient::Unauthorized => ex
    Rails.logger.error("Was unable to find linkedin data for #{username}")
    return []
  rescue LinkedIn::Unauthorized
    Rails.logger.error("Was unable to find linkedin data for #{username}")
    return []
  end

  def profile
    @profile ||= raw_profile
  end

  def build_education_name(education)
    if education.field_of_study
      "Studied #{education.field_of_study} at #{education.school_name}"
    elsif education.school_name
      education.school_name
    end
  end

  def build_name(position)
    if position.company
      [position.title, position.company.name].join(' at ')
    else
      position.title
    end
  end

  def build_end_date(position)
    Date.parse("#{position.end_year}/#{position.end_month}/01")
  rescue
    nil
  end

  def build_start_date(position)
    Date.parse("#{position.start_year}/#{position.start_month}/01")
  rescue
    Date.parse("#{position.start_year}/01/01")
  end

  def raw_profile
    client_token, client_secret = *username.split('::')

    client                      = LinkedIn::Client.new(KEY, SECRET)
    client.authorize_from_access(client_token, client_secret)
    data = client.profile(fields: %w(public-profile-url location:(name) first-name last-name three-current-positions three-past-positions primary-twitter-account industry summary specialties honors interests positions publications patents skills certifications educations mfeed-rss-url suggestions group-memberships main-address))
    data
  end
end