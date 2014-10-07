RSpec.describe ProtipsHelper, type: :helper do
  describe ".protip_search_results_to_render" do
    it 'has no protips to render' do
      expect(helper.protip_search_results_to_render(nil)).to be_nil
    end
  end

  describe '#users_background_image' do
    context 'user is logged in' do
      it 'returns #location_image_url_for @user' do
        assign(:user, 'test_user')
        allow(helper).to receive(:location_image_url_for).with('test_user').and_return('image_path')
        expect(helper.users_background_image).to eq 'image_path'
      end
    end

    context 'user is not logged in' do
      it 'returns nil' do
        assign(:user, nil)
        expect(helper.users_background_image).to be_nil
      end
    end

    context 'protip is set' do
      it 'returns #location_image_url_for @protip.user if @protip is not new_record' do
        @protip = double('protip', 'user' => 'test_user', 'new_record?' => false)
        allow(helper).to receive(:location_image_url_for).with('test_user').and_return('image_path')
        expect(helper.users_background_image).to eq 'image_path'
      end

      it 'returns nil if @protip is new_record' do
        @protip = double('protip', 'user' => 'test_user', 'new_record?' => true)
        expect(helper.users_background_image).to be_nil
      end
    end

    context 'protip is not set' do
      it 'returns nil' do
        assign(:protip, nil)
        expect(helper.users_background_image).to be_nil
      end
    end
  end

end
