class SpamReport < ActiveRecord::Base
  belongs_to :spammable, polymorphic: true
end
