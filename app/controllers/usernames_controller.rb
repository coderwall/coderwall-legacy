class UsernamesController < ApplicationController
  skip_before_action :require_registration

  def index
    # returns nothing if validation is run agains empty params[:id]
    render nothing: true
  end

  def show
    # allow validation to pass if it's the user's username that they're trying to validate (for edit username)
    if signed_in? && current_user.username.downcase == params[:id].downcase
      head :ok
    elsif User.find_by_username(params[:id]) || User::RESERVED.include?(params[:id].downcase)
      head :forbidden
    else
      head :ok
    end
  end
end
