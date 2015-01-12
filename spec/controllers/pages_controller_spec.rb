require 'spec_helper'

RSpec.describe PagesController, type: :controller do
  let(:unregistered_user) { Fabricate(:user, state: User::REGISTRATION) }

  it 'should be able to access privacy policy while user is logged in but not registered' do
    controller.send :sign_in, unregistered_user
    get :show, page: 'tos', layout: 'application'
    expect(response).to be_success
  end

  it 'fails when presented an non-whitelisted page' do
    controller.send :sign_in, unregistered_user
    expect { get :show, page: 'IMNOTREAL' }.to raise_error ActionController::RoutingError
  end

  it 'fails when presented an non-whitelisted layout' do
    controller.send :sign_in, unregistered_user
    expect { get :show, page: 'tos', layout: 'IMNOTREAL' }.to raise_error ActionController::RoutingError
  end
end
