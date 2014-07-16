class UsernamesController < ApplicationController
  skip_before_filter :require_registration

  def show
    # allow validation to pass if it's the user's username that they're trying to validate (for edit username)
    if signed_in? && current_user.username.downcase == params[:id].downcase
      head :ok
    elsif User.with_username(params[:id]) || User::RESERVED.include?(params[:id].downcase)
      head :forbidden
    else
      head :ok
    end
  end
end