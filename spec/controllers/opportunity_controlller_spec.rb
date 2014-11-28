require 'spec_helper'

RSpec.describe OpportunitiesController, type: :controller do

  it 'render #index' do
    get :index
    expect(response.status).to eq(200)
    expect(response).to render_template(['opportunities/index', 'layouts/jobs'])
  end

end
