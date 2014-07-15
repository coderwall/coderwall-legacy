module FollowsHelper
  def network_active_css_class(type)
    return 'current' if params[:type] == type
  end

  def show_owner_before_this_user?(follower)
    if @show_owner_before_this_user.nil? && @user.score_cache >= follower.score_cache
      @show_owner_before_this_user = true
      return true
    else
      return false
    end
  end

  def share_profile(text, user, html_options = {})
    query_string = {
      url: badge_url(username: user.username),
      text: 'Check out my awesome @coderwall and follow me',
      related: '',
      count: 'vertical',
      lang: 'en'
    }.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v)}" }.join('&')
    url = "#{TweetButton::TWITTER_SHARE_URL}?#{query_string}"
    link_to(text, url, html_options.reverse_merge(target: :new, class: 'track', 'data-action' => 'share profile'))
  end
end
