class HomeController < ApplicationController
  def index
    return redirect_to destination_url, flash: flash if signed_in?
  end
end
