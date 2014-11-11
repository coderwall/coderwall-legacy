Fabricator(:sent_mail) do
end

# == Schema Information
#
# Table name: sent_mails
#
#  id            :integer          not null, primary key
#  mailable_id   :integer
#  mailable_type :string(255)
#  user_id       :integer
#  sent_at       :datetime
#
