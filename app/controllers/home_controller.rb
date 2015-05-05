class HomeController < ApplicationController
  def index
    redirect_to destination_url, flash: flash if signed_in?
  end
end
