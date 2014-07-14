# == Schema Information
#
# Table name: highlights
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  featured    :boolean          default(FALSE)
#
# Indexes
#
#  index_highlights_on_featured  (featured)
#  index_highlights_on_user_id   (user_id)
#

Fabricator(:highlight) do

end
