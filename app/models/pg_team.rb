#Rename to Team when Mongodb is dropped
class PgTeam < ActiveRecord::Base
    self.table_name = 'teams'
    #TODO add inverse_of
    has_one :account, class_name: 'Teams::Account' , foreign_key: 'team_id'

    has_many :members, class_name: 'Teams::Member', foreign_key: 'team_id'
    has_many :links, class_name:  'Teams::Link', foreign_key: 'team_id'
    has_many :locations, class_name:  'Teams::Location' , foreign_key: 'team_id'
end