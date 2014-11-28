Fabricator(:protip_link) do
  identifier 1
  url 'MyString'
end

# == Schema Information
#
# Table name: protip_links
#
#  id         :integer          not null, primary key
#  identifier :string(255)
#  url        :string(255)
#  protip_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  kind       :string(255)
#
