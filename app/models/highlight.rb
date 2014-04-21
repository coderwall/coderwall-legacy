# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `highlights`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`created_at`**   | `datetime`         |
# **`description`**  | `text`             |
# **`featured`**     | `boolean`          | `default(FALSE)`
# **`id`**           | `integer`          | `not null, primary key`
# **`updated_at`**   | `datetime`         |
# **`user_id`**      | `integer`          |
#
# ### Indexes
#
# * `index_highlights_on_featured`:
#     * **`featured`**
# * `index_highlights_on_user_id`:
#     * **`user_id`**
#

class Highlight < ActiveRecord::Base
  belongs_to :user

  after_create :add_to_timeline

  def self.random(limit = 1)
    order("Random()").limit(limit)
  end

  def self.random_featured(limit = 1)
    where(featured: true).order("Random()").limit(limit).all(include: :user)
  end

  def event
    @event || nil
  end

  private
  def add_to_timeline
    @event = Event.create_highlight_event(self.user, self)
  end
end
