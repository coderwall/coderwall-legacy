require 'rails_helper'

RSpec.describe AvatarUploader do

  context 'user' do
    describe 'default url' do
      it 'should provide the default url' do
        user = Fabricate(:user)
        expect(user.avatar.url).to eq('/assets/user-avatar.png')
      end
    end
  end

  context 'team' do
    describe 'default url' do
      it 'should provide the default url' do
        team = Fabricate(:team)
        expect(team.avatar.url).to eq('/assets/team-avatar.png')
      end
    end
  end

end
