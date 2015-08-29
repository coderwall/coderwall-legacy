class HomeController < ApplicationController
  layout 'home4-layout'
  # GET                   /welcome(.:format)
  def index
    return redirect_to destination_url, flash: flash if signed_in?
  end
end
