module UserSearch
  extend ActiveSupport::Concern

  def public_hash(full=false)
    hash = { username:     username,
             name:         display_name,
             location:     location,
             endorsements: endorsements.count,
             team:         team_id,
             accounts:     { github: github },
             badges:       badges_hash = [] }
    badges.each do |badge|
      badges_hash << {
          name:        badge.display_name,
          description: badge.description,
          created:     badge.created_at,
          badge:       block_given? ? yield(badge) : badge
      }
    end
    if full
      hash[:about] = about
      hash[:title]              = title
      hash[:company]            = company
      hash[:specialities]       = speciality_tags
      hash[:thumbnail]          = avatar.url
      hash[:accounts][:twitter] = twitter
    end
    hash
  end

end