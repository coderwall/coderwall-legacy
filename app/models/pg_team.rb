#Rename to Team when Mongodb is dropped
class PgTeam < ActiveRecord::Base
    self.table_name = 'teams'
    has_one :account, class_name: 'Teams::Account'

    has_many :members, class_name: 'Teams::Member'
    has_many :links, class_name:  'Teams::Link'
    has_many :locations, class_name:  'Teams::Location'
end