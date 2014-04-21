require 'spec_helper'

describe PagesController do

  it 'should be able to access privacy policy while user is logged in but not registered' do
    unregisterd_user = Fabricate(:user, state: User::REGISTRATION)
    controller.send :sign_in, unregisterd_user
    get :show, page: 'tos'
    response.should be_success
  end

end