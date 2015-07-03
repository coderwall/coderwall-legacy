class Protip::Search::Scope < SearchModule::Search::Scope

  def to_hash
    case @domain
      when :user
        followings(@object)
      when :network
        network(@object)
    end
  end

  def followings(user)
    {
        or: [
            { terms: { "user.user_id" => [user.id] + user.following_users_ids + user.following_team_members_ids } },
            { terms: { "tags" => user.following_networks_tags } }
        ]
    }
  end

  def network(tag)
    tags =  Network.find_by_slug(tag.parameterize).try(:tags) || tag
    {
        terms: { tags: tags}
    }
  end
end