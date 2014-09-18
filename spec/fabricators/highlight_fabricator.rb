Fabricator(:highlight) do

end

# == Schema Information
# Schema version: 20140918031936
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
