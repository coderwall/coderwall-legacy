RSpec.describe AbuseMailer, type: :mailer do
  describe 'report_inappropriate' do

    let(:mail) { AbuseMailer.report_inappropriate(protip.to_param) }

    let!(:current_user) { Fabricate(:user, admin: true) }

    let(:protip) do
      Protip.create!(
        title: 'hello world',
        body: "somethings that's meaningful and nice",
        topic_list: %w(java javascript),
        user_id: current_user.id
      )
    end

    it 'renders the headers' do
      expect(mail.subject).to match('Spam Report for Protip: "hello world"')
      expect(mail.to).to eq(['someone@example.com'])
      expect(mail.from).to eq(['support@coderwall.com'])
    end

    #Use capybara
    it 'renders the body', skip: 'FIX ME' do
      expect(mail.body.encoded).to match("<header><h1>Spam Report for Protip</h1></header><hr /><section><h3>hello world</h3><a href=\"http://coderwall.com/p/06tlva\">22</a><div>by Matthew Deiters</div><div>Reported by: Anonymous User</div></section><footer><h5>Reported from IP:  </h5></footer>")
    end
  end
end
