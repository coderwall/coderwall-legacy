class ProviderUserLookupsController < ApplicationController

  # GET                   /providers/:provider/:username(.:format)
  def show
    service = ProviderUserLookupService.new params[:provider], params[:username]
    if user = service.lookup_user
      redirect_to badge_path(user.username)
    else
      redirect_to root_path, flash: { notice: 'User not found' }
    end
  end
end
