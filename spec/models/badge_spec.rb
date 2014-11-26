require 'spec_helper'

RSpec.describe Badge, type: :model do
  let(:badge) { Badge.new(badge_class_name: 'Polygamous') }

  it 'gets name from badge class' do
    expect(badge.display_name).to eq('Walrus')
  end

  it 'gets description from badge class' do
    expect(badge.description).to include('The walrus is no stranger')
  end

  it 'creates an image path from image name in class' do
    expect(badge.image_path).to eq('badges/walrus.png')
  end

end
