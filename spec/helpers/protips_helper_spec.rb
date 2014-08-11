RSpec.describe ProtipsHelper, type: :helper do
  describe ".protip_search_results_to_render" do
    it 'has no protips to render' do
      expect(helper.protip_search_results_to_render(nil)).to be_nil
    end
  end
end
