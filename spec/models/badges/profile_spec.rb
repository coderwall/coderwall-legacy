RSpec.describe 'profile badges', :type => :model do
  it 'mdeiters', functional: true, slow: true, skip: 'the data bootstrap is incorrect' do
    VCR.use_cassette('github_for_mdeiters') do
      User.delete_all
      Fact.delete_all
      @user = User.bootstrap('mdeiters', GITHUB_SECRET)

      badge = Charity.new(@user)
      expect(badge.award?).to eq(false)

      badge = Cub.new(@user)
      expect(badge.award?).to eq(false)

      badge = EarlyAdopter.new(@user)
      expect(badge.award?).to eq(true)
    end
  end

  it 'verdammelt', functional: true, slow: true do
    VCR.use_cassette('github_for_verdammelt') do
      User.delete_all
      @user = User.bootstrap('verdammelt', ENV['GITHUB_CLIENT_ID'])

      badge = Charity.new(@user)
      expect(badge.award?).to eq(true)
    end
  end

  it 'mrdg', functional: true, slow: true do
    VCR.use_cassette('github_for_mrdg') do
      User.delete_all
      @user = User.bootstrap('mrdg', ENV['GITHUB_CLIENT_ID'])
      badge = Cub.new(@user)
      expect(badge.award?).to eq(true)
    end
  end
end
