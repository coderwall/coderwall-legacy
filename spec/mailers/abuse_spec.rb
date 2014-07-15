RSpec.describe Abuse, type: :mailer do
  describe 'report_inappropriate' do

    let(:mail) { Abuse.report_inappropriate(protip_public_id: protip.to_param) }

    let(:current_user) { Fabricate(:user, admin: true) }

    let(:protip) do
      Protip.create!(
        title: 'hello world',
        body: "somethings that's meaningful and nice",
        topics: %w(java javascript),
        user_id: current_user.id
      )
    end

    it 'renders the headers' do
      expect(mail.subject).to match('Spam Report for Protip: "hello world"')
      expect(mail.to).to eq(['someone@example.com'])
      expect(mail.from).to eq(['support@coderwall.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("somethings that's meaningful and nice")
    end
  end
end
