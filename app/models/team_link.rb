# Postgresed  [WIP] : Teams::Link
class TeamLink
  include Mongoid::Document
  embedded_in :team

  field :name
  field :url
end
