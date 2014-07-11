class HomeController < ApplicationController
  layout 'home4-layout'

  def index
    return redirect_to destination_url, flash: flash if signed_in?
  end
end
