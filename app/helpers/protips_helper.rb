require 'cfm'

module ProtipsHelper

  def protip_search_results_to_render(protips)
    (protips.results if protips.respond_to?(:results)) || protips.try(:all)
  end

  def protip_summary
    "A protip by #{@protip.user.username} about #{@protip.topics.to_sentence}."
  end

  def right_border_css(text, width=6)
    "border-left: #{width}px solid ##{color_signature(text)}"
  end

  def bottom_border_css(text, width=6)
    "border-bottom: #{width}px solid ##{color_signature(text)}"
  end

  def color_signature(text)
    Digest::MD5.hexdigest("z#{text}").to_s[0..5].upcase
  end

  def youtube_embed(youtube_url)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    s = %Q(<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>)
    s
  end

  def to_tweet(text, url, hashes)
    tweet = truncate(text, length: (144-hashes.length-url.length-2))
    "#{tweet} #{hashes}"
  end

  def share_on_twitter(protip, klass='share-this')
    text = to_tweet(protip.title, protip_url(protip), "#protip")
    custom_tweet_button 'Share this', {text: text, via: 'coderwall', url: protip_url(protip)}, {class: klass + ' track', 'data-action' => 'share protip', 'data-from' => 'protip', target: :new}
  end

  def domain(url)
    url.split("/")[2]
  end

  def formatted_protip(protip)
    protip.to_html
  end

  def escape_scripts(text)
    escaped_text = text.gsub(/(<[^(>|\/)]*?script.*?>[^<]*?<.*?\/script.*?>)/, '    \1')
    escaped_text.gsub(/(<.*)on[a-z]+\s*=\s*[^ ]+([^>]*>)/i, "\1 \2")
  end

  def tags
    params[:tags] || []
  end

  def users_background_image
    if @user
      location_image_url_for(@user)
    elsif @protip && !@protip.new_record?
      location_image_url_for(@protip.user)
    end
  end

  def create_or_update_url(protip)
    url_for(action: protip.new_record? ? :create : :update, id: protip.public_id)
  end

  def tags_list
    params[:tags].split("/")
  end

  def searched_tags
    (params[:tags].nil? ? "" : tags_list.join("+"))
  end

  def relevant_topics_for_user(count)
    trending = trending_protips_topics(20)
    mutual = (current_user.skills.map(&:name) & trending).first(count)
    #mutual + (trending - mutual).first(count - mutual.size)
    mutual
  end

  def trending_protips_topics(count)
    Protip.trending_topics.first(count)
  end

  def trending_protips_for_topic(topic)
    Protip.trending.for_topic(topic)
  end

  def search_trending_protips_for_topic(topic, query=nil, page=params[:page], per_page=params[:per_page])
    Protip.search_trending_by_topic_tags(query, topic.to_a, page || 1, per_page || Protip::PAGESIZE)
  end

  def subscribe_to_topic(topic, additional_classes="", options={})
    link_to '', unsubscribe_protips_path(topic), options.merge(class: "protip-subscription subscribed #{additional_classes}", 'data-reverse-action' => subscribe_protips_path(topic))
  end

  def unsubscribe_from_topic(topic, additional_classes="", options={})
    link_to '', subscribe_protips_path(topic), options.merge(class: authenticated_class("protip-subscription #{additional_classes}"), 'data-reverse-action' => unsubscribe_protips_path(topic))
  end

  def subscription_link(topic, additional_classes="", options={})
    topic = topic.gsub(/^author:/, "") unless topic.is_a?(Array)
    if signed_in? and current_user.subscribed_to_topic?(topic)
      subscribe_to_topic(topic, additional_classes, options)
    else
      unsubscribe_from_topic(topic, additional_classes, options)
    end
  end

  def upvote_link(protip, classname)
    if protip.already_voted?(current_user, current_user.try(:tracking_code), request.remote_ip)
      content_tag :div, "#{protip.upvotes}", class: "upvoted #{classname}", itemprop: 'interactionCount'
    else
      link_to "#{protip.upvotes}", upvote_protip_path(protip.public_id), class: "#{classname} track", remote: true, method: :post, rel: "nofollow", 'data-action' => "upvote protip", 'data-from' => (classname == "small-upvote" ? 'mini protip' : 'protip'), itemprop: 'interactionCount'
    end
  end

  def protip_or_link_path(protip)
    if on_protip_from_search_page = params[:p] && params[:i]
      next_index_in_orginial_results = params[:i].to_i + 1
      protip_path(protip.public_id, q: params[:q], p: params[:p], t: params[:t], i: next_index_in_orginial_results)
    elsif protip.only_link?
      increment_index_so_pagination_in_protip_works = protip_result_index
      protip.link
    else
      protip_path(protip.public_id, search_params(protip_result_index))
    end
  end

  def search_params(index)
    search = {}
    search[:q] = @query || params[:q] || ""
    search[:p] = params[:page] || 1
    search[:t] = (@topics || params[:tags] || []).first(5)
    search[:i] = index unless search[:q].blank? && search[:t].blank? && @query.nil?
    search
  end

  def reset_protip_result_index
    @protip_result_index = 1
  end

  def protip_result_index
    return nil if @protip_result_index == nil
    val = @protip_result_index
    @protip_result_index = @protip_result_index + 1
    val
  end

  def search_protips_by_topics(topics)
    if signed_in?
      topics = topics.to_a unless topics.is_a? Array
      link_to('Search Protips', "#{tagged_protips_path(topics)}/search", id: 'open-search', class: 'slidedown', 'data-target' => 'search')
    else
      link_to('Search Protips', signin_path(flash: 'You must sign in before you can search.'), id: 'open-search')
    end
  end

  def top_trending_protips
    Protip.top_trending
  end

  def on_trending_page?
    params[:controller] == 'protips' && params[:action] == 'index'
  end

  def unsubscribable_topic?(topic, topics)
    topic.nil? or topics.size != 1
  end

  def search_target(init_target)
    params[:page].to_i == 0 ? init_target : init_target + " #more"
  end

  def search_results_replace_method
    params[:page].to_i == 0 ? "html" : "replaceWith"
  end

  def topics_to_query(topics)
    topics = topics.split(" + ") unless topics.nil? or topics.is_a? Array
    topics.map do |topic|
      if Protip::USER_SCOPE.include? topic or topic =~ /^team:/ or topic =~ /^author:/
        topic
      else
        "tagged:#{topic}"
      end
    end.join(" ") unless topics.nil?
  end

  def protips_back
    Rails.env.test? ? controller.request.env["HTTP_REFERER"] : 'javascript:history.back()'
  end

  def protip_query_options
    params.select { |k, v| ['q', 'page', 'per_page'].include? k }.to_json
  end

  def my_protips?(topics)
    topics.map do |topic|
      if Protip::USER_SCOPE_REGEX[:author] =~ topic || Protip::USER_SCOPE_REGEX[:bookmark] =~ topic
        return true
      end
    end unless topics.nil?
    false
  end

  def topics_to_sentence(topics)
    topics.nil? ? "" : topics.to_sentence.gsub(/<[^<>]*>#?([^<>]+)<\/\w+>/, '\1')
  end

  def protip_topic_page_title(topics)
    username = topics.is_a?(Array) ? (topics.size == 1 ? topics.first : nil) : topics
    unless username.nil? or (user = User.find_by_username(username)).blank?
      "Coderwall - Trending Pro tips by #{user.name}"
    else
      "Coderwall - Trending Pro tips #{"about #{topics_to_sentence(topics)} " unless topics.blank?}by top developers in the world!"
    end
  end

  def protip_topic_page_description(topics)
    "Trending #{topics_to_sentence(topics) unless topics.blank?} links, how-tos, tutorials and code-snippets shared by top #{topics_to_sentence(topics) unless topics.blank?} developers."
  end

  def protip_topic_page_keywords(topics)
    (topics_to_sentence(topics).split("and") + ["pro tips", "links", "tutorials", "how-tos"]).join(",").strip!
  end

  def formatted_comment(text)
    CFM::Markdown.render(text)
  end

  def can_edit_comment?(comment)
    is_admin? || comment.author_id == current_user.try(:id)
  end

  def comment_liked_class(comment)
    comment.likes_cache > 0 ? "liked" : "not-liked"
  end

  def comment_likes(comment)
    comment.likes_cache > 0 ? comment.likes_cache.to_s : ""
  end

  def top_comment?(comment, index)
    index == 0 && comment.likes_cache > 0
  end

  def comment_author?(comment)
    comment.author_id == current_user.try(:id)
  end

  def protip_reviewer(protip)
    @reviewer.nil? ? "not yet reviewed" : "reviewed by #{@reviewer.username}"
  end

  def follow_or_following(user)
    signed_in? && current_user.following?(user) ? "following" : "follow"
  end

  def selected_search_context_class(chosen)
    @context == chosen ? "selected" : ""
  end

  def display_search_class
    @context == "search" ? "" : "hide"
  end

  def display_scopes_class
    @context == "search" ? "hide" : ""
  end

  def display_scope_class
    @scope.nil? || params[:action] == 'search' ? "everything" : "following"
  end

  def current_user_upvotes
    @upvoted_protip_ids ||= current_user.upvoted_protips.pluck(:public_id)
  end

  def user_upvoted?(protip)
    current_user && current_user_upvotes.include?(protip.public_id)
  end

  def formatted_best_stat_value(protip)
    value = case best_stat_name(protip).to_sym
            when :views
              views_stat_value(protip)
            else
              best_stat_value(protip)
            end

    number_to_human(value, units: { unit: '', thousand: 'k' })
  end

  def best_stat_name(protip)
    protip.best_stat.is_a?(Tire::Results::Item) ? protip.best_stat.name : protip.best_stat[0]
  end

  def views_stat_value(protip)
    best_stat_value(protip) * Protip::COUNTABLE_VIEWS_CHUNK
  end

  def best_stat_value(protip)
    protip.best_stat.is_a?(Tire::Results::Item) ? protip.best_stat.value.to_i : protip.best_stat[1]
  end

  def blur_protips?
    params[:show_all].nil? && !signed_in?
  end

  def followings_fragment_cache_key(user_id)
    ['v1', 'followings_panel', user_id]
  end

  def protip_networks(protip)
    protip.networks.respond_to?(:[]) ? protip.networks.map(&:name).map(&:downcase) : protip.networks.split(",")
  end

  def protip_owner?(protip, user)
    user && protip.user && protip.user.username == user.username
  end

  def get_uncached_version?(protip, mode)
    protip_owner?(protip, current_user) || is_admin? || mode == 'preview'
  end

  def featured_team_banner(team)
    unless team.featured_banner_image.blank?
      team.featured_banner_image
    else
      !team.big_image.blank? ? team.big_image : default_featured_job_banner
    end
  end

  def default_featured_job_banner
    "home-top-bg.jpg"
  end

  def protip_display_mode
    mobile_device? ? "fullpage" : "popup"
  end

  def display_protip_stats?(protip)
    stat_name = best_stat_name(protip)
    # if stat is present, and the stat we're displaying is views over 50, display.
    # otherwise, we're showing stats for something other than views.
    return true if protip.best_stat.present? && stat_name == :views && views_stat_value(protip) > 50
    return true if protip.best_stat.present? && stat_name != :views
    return false
  end

  def protip_editing_text
    params[:action] == 'new' ? 'Add new protip' : 'Edit protip'
  end
end
