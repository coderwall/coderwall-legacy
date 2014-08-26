require 'rails_helper'

RSpec.describe ProtipMailer, :type => :mailer do
  describe "popular_protips" do
    let(:mail) { ProtipMailer.popular_protips(@from, @to) }

    before do
      @from = 30.days.ago
      @to = 0.days.ago
    end

    it 'renders the headers' do
      expect(mail.subject).to match('Popular Protips on Coderwall')
      expect(mail.to).to eq(['someone@example.com'])
      expect(mail.from).to eq(['support@coderwall.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("somethings that's meaningful and nice")
    end
  end


  describe ProtipMailer::Queries do
    it 'queries for the popular protips since a date' do
      from = 1.day.ago
      to = 0.days.ago
      ap results = ProtipMailer::Queries.popular_protips(from, to)
    end
  end
end
