require 'spec_helper'

RSpec.describe PagesController, :type => :controller do
  it 'should be able to access privacy policy while user is logged in but not registered' do
    unregisterd_user = Fabricate(:user, state: User::REGISTRATION)
    controller.send :sign_in, unregisterd_user
    get :show, page: 'tos', layout: 'application'
    expect(response).to be_success
  end

  it 'fails when presented an non-whitelisted page' do
    unregisterd_user = Fabricate(:user, state: User::REGISTRATION)
    controller.send :sign_in, unregisterd_user

    expect { get :show, page: 'IMNOTREAL' }.to raise_error 'Invalid page: IMNOTREAL'
  end

  it 'fails when presented an non-whitelisted layout' do
    unregisterd_user = Fabricate(:user, state: User::REGISTRATION)
    controller.send :sign_in, unregisterd_user

    expect { get :show, page: 'tos', layout: 'IMNOTREAL' }.to raise_error 'Invalid layout: IMNOTREAL'
  end
end
