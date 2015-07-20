# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  title              :string(50)       default("")
#  comment            :text             default("")
#  protip_id          :integer
#  user_id            :integer
#  likes_cache        :integer          default(0)
#  likes_value_cache  :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  likes_count        :integer          default(0)
#  user_name          :string(255)
#  user_email         :string(255)
#  user_agent         :string(255)
#  user_ip            :inet
#  request_format     :string(255)
#  spam_reports_count :integer          default(0)
#  state              :string(255)      default("active")
#

Fabricator(:comment) do
  body { 'Lorem Ipsum is simply dummy text...' }
  protip { Fabricate.build(:protip) }
  user { Fabricate.build(:user) }
end
