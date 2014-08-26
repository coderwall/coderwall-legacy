module UsersHelper

  def show_private_message?
    if cookies[:identity] == params[:username] && (cookies[:show_private_message] ||= 1).to_i <= 2
      cookies[:show_private_message] = cookies[:show_private_message].to_i + 1
      true
    else
      false
    end
  end

  def avatar_image_tag(user, options = {})
    options['data-user'] = user.username
    link_to(
        users_image_tag(user),
        badge_path(username: user.username), options
    )
  end

  def users_team_image_tag(user, options = {})
    return image_tag(user.team_avatar, options) unless user.team_avatar.blank?
    users_image_tag(user, options)
  end

  def users_image_tag(user, options = {})
    options[:class] ||= 'avatar'
    options[:alt] ||= user.username
    image_tag(users_image_path(user), options)
  end

  #TODO Remove
  def users_image_path(user)
    return ''
    user.avatar.url
  end

  def user_or_team_image_path(user_or_team)
    user_or_team.is_a?(User) ? users_image_path(user_or_team) : user_or_team.avatar_url
  end

  def remaining_bookmarks(user)
    bookmarks = []
    if user.linkedin_token.blank?
      bookmarks << social_bookmark('linkedin', link_linkedin_path, 'Link your LinkedIn account', 'needtolink')
    end
    if user.twitter_token.blank?
      bookmarks << social_bookmark('twitter', link_twitter_path, 'Link your Twitter account', 'needtolink')
    end
    if user.github.blank?
      bookmarks << social_bookmark('github', link_github_path, 'Link your GitHub account', 'needtolink')
    end
    bookmarks
  end

  def social_bookmarks(user)
    bookmarks = []
    bookmarks << social_bookmark('github', "https://github.com/" + user.github) unless user.github.blank?
    if viewing_self?
      bookmarks << social_bookmark('linkedin', linkedin_url(user)) unless user.linkedin_token.blank?
      bookmarks << social_bookmark('twitter', "https://twitter.com/" + user.twitter, "@#{user.twitter}") unless user.twitter_token.blank?
    else
      bookmarks << social_bookmark('linkedin', linkedin_url(user)) unless user.linkedin.blank? && user.linkedin_legacy.blank? && user.linkedin_public_url.blank?
      bookmarks << social_bookmark('twitter', "https://twitter.com/" + user.twitter, "@#{user.twitter}") unless user.twitter.blank?
    end
    bookmarks << social_bookmark('blog', user_blog_url(user.blog)) unless user.blog.blank?
    bookmarks << social_bookmark('bitbucket', "https://bitbucket.org/" + user.bitbucket) unless user.bitbucket.blank?
    bookmarks << social_bookmark('codeplex', "http://www.codeplex.com/site/users/view/" + user.codeplex) unless user.codeplex.blank?
    bookmarks << social_bookmark('forrst', "http://forrst.com/people/" + user.forrst) unless user.forrst.blank?
    bookmarks << social_bookmark('dribbble', "http://dribbble.com/" + user.dribbble) unless user.dribbble.blank?
    bookmarks << social_bookmark('stackoverflow', "http://stackoverflow.com/users/" + user.stackoverflow) unless user.stackoverflow.blank?
    bookmarks << social_bookmark('slideshare', "http://www.slideshare.net/" + user.slideshare) unless user.slideshare.blank?
    bookmarks << social_bookmark('speakerdeck', "http://speakerdeck.com/u/" + user.speakerdeck) unless user.speakerdeck.blank?
    bookmarks << social_bookmark('sourceforge', "http://sourceforge.net/users/" + user.sourceforge) unless user.sourceforge.blank?
    bookmarks << social_bookmark('googlecode', "http://code.google.com/u/" + user.google_code) unless user.google_code.blank?
    bookmarks
  end

  def social_bookmark(name, link, title = nil, css_class=nil)
    "<li>" + link_to("<span>#{name}</span>".html_safe, link, class: "tip track #{css_class} #{name}", title: (title || name), target: :new, 'data-action' => "view user's #{name}", rel: 'me') + "</li>"
  end

  def linkedin_url(user)
    if !user.linkedin_public_url.blank?
      user.linkedin_public_url
    elsif !user.linkedin.blank?
      "http://www.linkedin.com/in/#{user.linkedin}"
    else #user gave us a url, not a username
      if user.linkedin_legacy
        if user.linkedin_legacy.match(/\Ahttp/)
          user.linkedin_legacy
        else
          "http://www.linkedin.com/in/#{user.linkedin_legacy}"
        end
      end
    end
  end

  def user_blog_url(blog)
    if blog.match(/http/)
      blog
    else
      "http://" + blog
    end
  end

  def business_card_for(user)
    user.title.blank? ? nil : user.title
    # title   = user.title.blank? ? nil : user.title
    # company = user.company.blank? ? nil : user.company
    # [title, company].compact.join(" at ")
  end

  def custom_stats
    @user.stats.select { |stat| stat.name.to_s == 'custom' }
  end

  def empty_stats
    3 - custom_stats.size
  end

  def estimated_delivery_date
    if  Date.today.end_of_week == Date.today
      Date.today + 7.days
    else
      Date.today.end_of_week
    end
  end

  def markdown_embed_code_with_count
    "[![endorse](https://api.coderwall.com/#{current_user.username}/endorsecount.png)](https://coderwall.com/#{current_user.username})"
  end

  def markdown_embed_code_no_count
    "[![endorse](https://api.coderwall.com/#{current_user.username}/endorse.png)](http://coderwall.com/#{current_user.username})"
  end

  def textile_embed_code_with_count
    "\"!https://api.coderwall.com/#{current_user.username}/endorsecount.png!\":https://coderwall.com/#{current_user.username}"
  end

  def textile_embed_code_no_count
    "\"!https://api.coderwall.com/#{current_user.username}/endorse.png!\":https://coderwall.com/#{current_user.username}"
  end

  def html_embed_code_with_count
    link_to badge_url(current_user.username) do
      image_tag "https://api.coderwall.com/#{current_user.username}/endorsecount.png", alt: "Endorse #{current_user.github} on Coderwall"
    end
  end

  def social_tag(type, user)
    if (content = user.send(type)).blank?
      nil
    else
      content_tag(:span, class: "alias") {
        content_tag(:span, " ", class: "social-icon #{type}") +
            content_tag(:span, content)
      }
    end
  end

  def event_checkin_class
    if viewing_self? && cookies['eventCheckin'] == 'nodesummit'
      'show'
    else
      'hide'
    end
  end

  def emit_date_li(item)
    if @last_date.nil?
      @last_date = item.nil? ? Date.today : item.date.strftime("%^b '%y")
      return "<li class='date'><div class='datestamp first'>This Month</div></li>"
    elsif @last_date != item.date.strftime("%^b '%y")
      @last_date = item.date.strftime("%^b '%y")
      return "<li class='date'><div class='datestamp'>" + @last_date + "</div></li>"
    end
    return ''
  end

  def location_image_tag_credits_for(user)
    photo = LocationPhoto.for(user, params[:location])
    link_to("photo of #{photo.location} by #{photo.author}".downcase, photo.url, rel: 'nofollow', target: :new)
  end

  def location_image_tag_for(user, options = {})
    image_tag(location_image_url_for(user), options)
  end

  def location_image_url_for(user)
    if user.banner.blank?
      photo = LocationPhoto.for(user, params[:location])
      asset_path("locations/#{photo.image_name}")
    else
      user.banner_url
    end
  end

  def team_banner_image_for(member)
    unless member.team_banner.blank?
      member.team_banner
    else
      location_image_url_for(member)
    end
  end

  def achievements_last_reviewed
    if reviewed_all_achievements?
      "Achievements last reviewed #{time_ago_in_words(@user.achievements_checked_at)} ago"
    else
      "We are still working on awarding you more achievements. Make sure you have link your Twitter, GitHub, and LinkedIn accounts if you have them."
    end
  end

  def skill_event_message(skill)
    message = []
    message << "spoken at #{pluralize(skill.speaking_events.size, 'event')}" if skill.speaking_events.size > 0
    message << "attended #{pluralize(skill.attended_events.size, 'event')}" if skill.attended_events.size > 0
    "Has #{message.join(' and ')}"
  end

  def recent_protips(count)
    @user.protips.recent(count)
  end

  def not_signedin_class
    return nil if signed_in?
    'not-signed-in'
  end
end
