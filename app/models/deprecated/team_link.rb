# Postgresed  [WIP] : Teams::Link
module Deprecated
  class TeamLink
    include Mongoid::Document
    embedded_in :team

    field :name
    field :url
  end
end
