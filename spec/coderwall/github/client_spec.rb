describe Coderwall::Github::Client do
  subject { Coderwall::Github::Client }

  let(:coderwall_user) { Fabricate(:user) }

  describe "#new" do
    context 'valid instance' do
      let(:valid_instance) { subject.new(coderwall_user.github_token) }

      it 'creates an instance of the client' do
        expect(valid_instance.client).to_not be_nil
      end

      it 'sets the access token' do
        expect(valid_instance.access_token).to be == coderwall_user.github_token
      end
    end

    context 'invalid instance' do
      it 'fails when github_access_token is nil' do
        expect{ subject.new(nil) }.to raise_error(Coderwall::Github::MissingAccessTokenError)
      end

      it 'fails when github_access_token is blank string' do
        expect{ subject.new('   ') }.to raise_error(Coderwall::Github::InvalidAccessTokenError)
      end

      [Array.new, Hash.new, Object.new, 1].each do |invalid_type|
        it "fails when github_access_token is a #{invalid_type}" do
          expect{ subject.new(invalid_type) }.to raise_error(Coderwall::Github::InvalidAccessTokenError)
        end
      end
    end
  end
end
