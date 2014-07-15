require 'digest/md5'

module BadgesHelper
  def share_coderwall_on_twitter
    text = 'Trying to cheat the system so I can check out my geek cred'
    custom_tweet_button 'Expedite my access', { text: text, via: 'coderwall' }, class: 'track expedite-access', 'data-action' => 'share achievement', 'data-action' => 'instantaccess'
  end

  def dom_tag(tag)
    sanitize_dom_id(tag).gsub(' ', '-').gsub('+', 'plus').gsub('#', 'sharp')
  end

  def dom_for_badge(badge)
    if badge.is_a?(Badge)
      badge.badge_class.name
    else
      badge.name
    end
  end

  def unlocked_badge_message
    "#{@user.display_name} unlocked the #{@badge.display_name} achievement for #{@badge.for} #{@badge.friendly_percent_earned} of developers on Coderwall have earned this."
  end

  def unlocked_badge_title
    "#{@user.short_name} leveled up and unlocked the #{@badge.display_name} on Coderwall"
  end
end
