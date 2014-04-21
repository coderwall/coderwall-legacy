describe Abuse do
  describe 'report_inappropriate' do

    let(:mail) { Abuse.report_inappropriate({ protip_public_id: protip.to_param }) }

    let(:current_user) { Fabricate(:user, admin: true) }

    let(:protip) {
      Protip.create!(
        title: "hello world",
        body: "somethings that's meaningful and nice",
        topics: ["java", "javascript"],
        user_id: current_user.id
      )
    }

    it 'renders the headers' do
      mail.subject.should match('Spam Report for Protip: "hello world"')
      mail.to.should eq(['someone@example.com'])
      mail.from.should eq(['support@coderwall.com'])
    end

    it 'renders the body' do
      mail.body.encoded.should match("somethings that's meaningful and nice")
    end
  end
end

