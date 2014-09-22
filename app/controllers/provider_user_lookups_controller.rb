require Rails.root.join('app/services/provider_user_lookup_service')

class ProviderUserLookupsController < ApplicationController
  def show
    service = Services::ProviderUserLookupService.new params[:provider], params[:username]
    if user = service.lookup_user
      redirect_to badge_path(user.username)
    else
      redirect_to root_path, flash: { notice: 'User not found' }
    end
  end
end
