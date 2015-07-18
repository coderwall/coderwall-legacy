class AddMissingFKs < ActiveRecord::Migration
  def change
    add_column :facts , :user_id, :integer
    drop_table :reserved_teams
    add_foreign_key 'facts', 'users', name: 'facts_user_id_fk', dependent: :delete
    add_foreign_key 'badges', 'users', name: 'badges_user_id_fk', dependent: :delete
    add_foreign_key 'comments', 'users', name: 'comments_user_id_fk', dependent: :delete
    add_foreign_key 'endorsements', 'users', name: 'endorsements_endorsed_user_id_fk', column: 'endorsed_user_id', dependent: :delete
    add_foreign_key 'endorsements', 'users', name: 'endorsements_endorsing_user_id_fk', column: 'endorsing_user_id', dependent: :delete
    add_foreign_key 'endorsements', 'skills', name: 'endorsements_skill_id_fk', dependent: :delete
    add_foreign_key 'followed_teams', 'teams', name: 'followed_teams_team_id_fk'
    add_foreign_key 'followed_teams', 'users', name: 'followed_teams_user_id_fk', dependent: :delete
    add_foreign_key 'invitations', 'users', name: 'invitations_inviter_id_fk', column: 'inviter_id'
    add_foreign_key 'invitations', 'teams', name: 'invitations_team_id_fk', dependent: :delete
    add_foreign_key 'likes', 'users', name: 'likes_user_id_fk'
    add_foreign_key 'network_hierarchies', 'networks', name: 'network_hierarchies_ancestor_id_fk', column: 'ancestor_id'
    add_foreign_key 'network_hierarchies', 'networks', name: 'network_hierarchies_descendant_id_fk', column: 'descendant_id'
    add_foreign_key 'network_protips', 'networks', name: 'network_protips_network_id_fk'
    add_foreign_key 'network_protips', 'protips', name: 'network_protips_protip_id_fk'
    add_foreign_key 'networks', 'networks', name: 'networks_parent_id_fk', column: 'parent_id'
    add_foreign_key 'opportunities', 'teams', name: 'opportunities_team_id_fk'
    add_foreign_key 'pictures', 'users', name: 'pictures_user_id_fk'
    add_foreign_key 'protip_links', 'protips', name: 'protip_links_protip_id_fk'
    add_foreign_key 'protips', 'users', name: 'protips_user_id_fk', dependent: :delete
    add_foreign_key 'seized_opportunities', 'opportunities', name: 'seized_opportunities_opportunity_id_fk', dependent: :delete
    add_foreign_key 'seized_opportunities', 'users', name: 'seized_opportunities_user_id_fk'
    add_foreign_key 'sent_mails', 'users', name: 'sent_mails_user_id_fk'
    add_foreign_key 'skills', 'users', name: 'skills_user_id_fk', dependent: :delete
    add_foreign_key 'taggings', 'tags', name: 'taggings_tag_id_fk'
    add_foreign_key 'teams_account_plans', 'teams_accounts', name: 'teams_account_plans_account_id_fk', column: 'account_id'
    add_foreign_key 'teams_account_plans', 'plans', name: 'teams_account_plans_plan_id_fk'
    add_foreign_key 'teams_accounts', 'users', name: 'teams_accounts_admin_id_fk', column: 'admin_id'
    add_foreign_key 'teams_accounts', 'teams', name: 'teams_accounts_team_id_fk', dependent: :delete
    add_foreign_key 'teams_links', 'teams', name: 'teams_links_team_id_fk', dependent: :delete
    add_foreign_key 'teams_locations', 'teams', name: 'teams_locations_team_id_fk', dependent: :delete
    add_foreign_key 'teams_members', 'teams', name: 'teams_members_team_id_fk', dependent: :delete
    add_foreign_key 'teams_members', 'users', name: 'teams_members_user_id_fk'
    add_foreign_key 'user_events', 'users', name: 'user_events_user_id_fk'
    add_foreign_key 'users_github_organizations_followers', 'users_github_organizations', name: 'users_github_organizations_followers_organization_id_fk', column: 'organization_id', dependent: :delete
    add_foreign_key 'users_github_organizations_followers', 'users_github_profiles', name: 'users_github_organizations_followers_profile_id_fk', column: 'profile_id'
    add_foreign_key 'users_github_profiles_followers', 'users_github_profiles', name: 'users_github_profiles_followers_follower_id_fk', column: 'follower_id', dependent: :delete
    add_foreign_key 'users_github_profiles_followers', 'users_github_profiles', name: 'users_github_profiles_followers_profile_id_fk', column: 'profile_id'
    add_foreign_key 'users_github_profiles', 'users', name: 'users_github_profiles_user_id_fk'
    add_foreign_key 'users_github_repositories_contributors', 'users_github_profiles', name: 'users_github_repositories_contributors_profile_id_fk', column: 'profile_id'
    add_foreign_key 'users_github_repositories_contributors', 'users_github_repositories', name: 'users_github_repositories_contributors_repository_id_fk', column: 'repository_id', dependent: :delete
    add_foreign_key 'users_github_repositories_followers', 'users_github_profiles', name: 'users_github_repositories_followers_profile_id_fk', column: 'profile_id'
    add_foreign_key 'users_github_repositories_followers', 'users_github_repositories', name: 'users_github_repositories_followers_repository_id_fk', column: 'repository_id', dependent: :delete
    add_foreign_key 'users_github_repositories', 'users_github_organizations', name: 'users_github_repositories_organization_id_fk', column: 'organization_id'
    add_foreign_key 'users_github_repositories', 'users_github_profiles', name: 'users_github_repositories_owner_id_fk', column: 'owner_id'
    add_foreign_key 'users', 'teams', name: 'users_team_id_fk'
  end
end
