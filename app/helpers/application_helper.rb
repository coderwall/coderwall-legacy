module ApplicationHelper
  include TweetButton

  def link_twitter_path
    '/auth/twitter'
  end

  def link_linkedin_path
    '/auth/linkedin'
  end

  def link_developer_path
    '/auth/developer'
  end

  def link_github_path
    '/auth/github'
  end

  def signup_via_email
    mail_to "support@coderwall.com", "But I don't have a GitHub account",
            subject: 'Let me in!',
            body: "I don't have a GitHub account but would like to be notified when Coderwall expands features beyond GitHub."
  end

  def greeting
    'Greetings'
  end

  def page_title(override_from_haml = nil)
    return override_from_haml unless override_from_haml.blank?
    if viewing_self?
      if @user.pending?
        "coderwall.com : your profile (in queue)"
      else
        "coderwall.com : your profile"
      end
    elsif @user
      if @user.pending?
        "coderwall.com : #{@user.display_name}'s profile (heavy lifting in progress)"
      else
        "coderwall.com : #{@user.display_name}'s profile"
      end
    else
      "coderwall.com : establishing geek cred since 1305712800"
    end
  end

  def standard_description
    "Coderwall is a space for tech's most talented makers to connect, share, build, and be inspired"
  end

  def page_description(description=nil)
    if @user
      description = "#{@user.display_name}'s achievements."
    else
      #"Coderwall is a community of developers and the teams they work on fundamentally changing how you find your next job"
      description = description || "Coderwall is a space for tech's most talented makers to connect, share, build, and be inspired"
    end
    description + " " + standard_description
  end

  def page_keywords(keywords=nil)
    if @user
      "#{@user.username}, developer, programmer, open source, resume, portfolio, achievements, badges, #{@user.speciality_tags.join(', ')}"
    else
      [keywords, "developers, engineers, open source, resume, portfolio, achievements, badges, job, jobs, job sites, it jobs, computer jobs, engineering jobs, technology jobs, ruby, java, nodejs, .net, python, php, perl"].join(",")
    end
  end

  def blog_posts_nav_class
    if params[:controller] == "blogs"
      'active'
    else
      nil
    end
  end

  def settings_nav_class
    if params[:controller] == "users" && params[:action] == "edit"
      'active'
    else
      nil
    end
  end

  def signin_nav_class
    if params[:controller] == "sessions" && params[:action] == "signin"
      'active'
    else
      nil
    end
  end

  def signup_nav_class
    if params[:controller] == "sessions" && params[:action] == "new"
      'active'
    else
      nil
    end
  end

  def protip_nav_class
    if params[:controller] == "protips" && params[:action] == "index"
      'active'
    else
      nil
    end
  end

  def network_nav_class
    if params[:controller] == "networks"
      'active'
    else
      nil
    end
  end

  def connections_nav_class
    if params[:controller] == "follows"
      'active'
    else
      nil
    end
  end

  def team_nav_class
    if params[:controller] == "teams" && params[:action] != 'index'
      if signed_in? && current_user.team_document_id == params[:id] || params[:id].blank?
        'active'
      else
        nil
      end
    else
      nil
    end
  end

  def teams_nav_class
    if params[:controller] == "teams" && params[:action] == 'index'
      'active'
    else
      nil
    end
  end

  def jobs_nav_class
    if params[:controller] == "opportunities" && params[:action] == 'index'
      'active'
    else
      nil
    end
  end

  def mywall_nav_class
    not_on_reviewing_achievement_page = params[:id].blank?
    not_on_followers = connections_nav_class.nil?
    if signed_in? && params[:username] == current_user.username && not_on_followers && not_on_reviewing_achievement_page && params[:controller] == "users"
      'active'
    else
      nil
    end
  end

  def trending_nav_class
    if params[:controller].to_sym == :links
      'active'
    else
      nil
    end
  end

  def user_endorsements
    endorsements = []

    # https://twitter.com/#!/iamdustan/status/104652472181719040
    endorsements << [User.find_by_username('iamdustan'), "One of the geekiest (and coolest) things I've seen in quite a while"]

    # https://twitter.com/#!/ang3lfir3/status/72810316882391040
    endorsements << [User.find_by_username('ang3lfir3'), "the companies I *want* to work for... care about the info on @coderwall"]

    # https://twitter.com/#!/chase_mccarthy/status/75582647396614145
    endorsements << [User.find_by_username('ozone1015'), "@coderwall is an awesome idea. It's like having Halo achievements for your resume!!!"]

    # https://twitter.com/#!/razorjack/status/75125655322374144
    endorsements << [User.find_by_username('RazorJack'), "@coderwall is awesome but everyone already knows it."]

    # https://twitter.com/#!/kennethkalmer/status/86392260555587584
    endorsements << [User.find_by_username('kennethkalmer'), "@coderwall really dishes out some neat achievements, hope this helps motivate even more folks to contribute to FOSS"]

    # endorsements << [User.with_username('jeffhogan'), 'I really dig @coderwall...I see great potential in utilizing @coderwall for portfolio/linkedin/professional ref. for developers!']

    endorsements
  end

  def record_event(name, options = {})
    "logUsage('#{name}', null, #{options.to_json});".html_safe
  end

  def profile_path(username)
    #this is here because its really slow to use badges_url named routes. For example it adds a whole second to leaderboar
    "/#{username}"
  end

  def user_or_team_profile_path(user_or_team)
    user_or_team.is_a?(User) ? profile_path(user_or_team.username) : team_path(user_or_team)
  end

  def tracking_code
    (current_user && current_user.tracking_code) || cookies[:trc]
  end

  def hide_all_but_first
    return 'hide' if !@hide_all_but_first.nil?
    @hide_all_but_first = 'hide'
    nil
  end

  def topic_protips_path(topic)
    user = topic.is_a?(Array) ? (topic.size == 1 ? topic.first : nil) : topic
    if User.exists?(username: user)
      user_protips_path(user)
    else
      tagged_protips_path(topic)
    end
  end

  def topics_protips_path(topics)
    tagged_protips_path(tags: topics)
  end

  def authenticated_class(classname)
    signed_in? ? classname : "#{classname} .noauth"
  end

  def follow_team_link(team)
    if signed_in? && current_user.following_team?(team)
      link_to('', follow_team_path(team), method: :post, remote: true, class: 'follow-team add-to-network following')
    elsif signed_in?
      link_to('', follow_team_path(team), method: :post, remote: true, class: 'follow-team add-to-network')
    else
      link_to('', root_path(flash: 'You must signin or signup before you can follow a team'), class: 'follow-team add-to-network noauth')
    end
  end

  def referrer_is_coderwall?
    return false if request.env['HTTP_REFERER'].blank?
    referrer = URI.parse(request.env['HTTP_REFERER'])
    referrer.host == request.env['SERVER_NAME'] || referrer.host == URI.parse(request.env['REQUEST_URI']).host
  end

  def follow_coderwall_on_twitter(text='Follow us on twitter', show_count=false)
    link_to(text, 'http://twitter.com/coderwall', target: :new, class: 'twitter-follow-button', 'data-show-count' => show_count)
  end

  def admin_stat_class(yesterday, today)
    today > yesterday ? "goodday" : "badday"
  end

  def mperson
    "http://data-vocabulary.org/Person"
  end

  def maddress
    "http://data-vocabulary.org/Address"
  end

  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = request.nil? ? "#{root_url}#{abs_path}" : "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end

  def number_to_word(number)
    case number
      when 1
        "one"
      when 2
        "two"
      when 3
        "three"
      when 4
        "four"
      when 5
        "five"
      when 6
        "six"
      when 7
        "seven"
      when 8
        "eight"
      when 9
        "nine"
      when 10
        "ten"
      else
        number.to_s
    end
  end

  def record_view_event(page_name)
    record_event("viewed", what: "#{page_name}")
  end

  def main_content_wrapper(omit)
    omit.blank? ? true : false
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    elsif params[:mobile] == "force"
      true
    else
      !(request.user_agent =~ /Mobile|webOS/).nil?
    end
  end

  def cc_attribution(username, link='http://creativecommons.org/licenses/by-sa/2.0/')
    haml_tag(:div, class: "cc") do
      haml_concat link_to image_tag("https://d3levm2kxut31z.cloudfront.net/assets/cclicense-91f45ad7b8cd17d1c907d4bdb2bf4852.png", title: "Creative Commons Attribution-Share Alike 2.0 Generic License", alt: "Creative Commons Attribution-Share Alike 2.0 Generic License"), 'http://creativecommons.org/licenses/by-sa/2.0/'
      haml_tag(:span) do
        haml_concat link_to("photo by #{username}", link)
      end
    end
  end

  def cc_attribution_for_location_photo(location)
    photo = LocationPhoto::Panoramic.for(location)
    cc_attribution(photo.try(:author), photo.try(:url))
  end

end
