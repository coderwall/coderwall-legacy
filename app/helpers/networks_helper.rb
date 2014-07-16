module NetworksHelper

  def alphabets
    ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
  end

  def top_networks_starting_with(networks, character)
    networks.select { |network| network.name[0].capitalize == character.capitalize }
  end

  def selected_class(tab)
    params[:sort] == tab || params[:filter] == tab || params[:action] == tab ? "active" : ""
  end

  def networks_nav_class(action)
    params[:action].to_sym == action ? "current" : ""
  end

  def networks_sub_nav_class(sort)
    if [:user, :featured].include? params[:action]
      "hide"
    elsif params[:sort] == sort
      "current"
    else
      ""
    end
  end

  def join_or_leave_class(network)
    current_user && current_user.member_of?(network) ? "member" : "join"
  end

  def join_or_leave_label(network)
    join_or_leave_class(network).capitalize
  end

  def join_or_leave_tracking(network)
    join_or_leave_class(network) == "member" ? "leave" : "join"
  end

  def join_or_leave_path(network)
    if signed_in?
      current_user.member_of?(network) ? leave_network_path(network.slug) : join_network_path(network.slug)
    else
      signup_path
    end
  end

  def determine_networks_partial(sort)
    if sort.blank? or sort == 'a_z'
      'alphabetized_list'
    else
      'list'
    end
  end

  def new_network?(network)
    network.created_at > 2.weeks.ago && network.created_at > Date.parse('03/08/2012') #launch date
  end

  def add_network_url
    is_admin? ? new_network_path : 'mailto:support@coderwall.com?subject='+"Request for a new network"
  end

end