RSpec.describe AbuseMailer, :type => :mailer do
  describe 'report_inappropriate' do

    let(:mail) { AbuseMailer.report_inappropriate(protip.to_param) }

    let!(:current_user) { Fabricate(:user, admin: true) }

    let(:protip) {
      Protip.create!(
        title: "hello world",
        body: "somethings that's meaningful and nice",
        topics: ["java", "javascript"],
        user_id: current_user.id
      )
    }

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

