class UsernamesController < ApplicationController
  skip_before_filter :require_registration

  def show
    if User.with_username(params[:id]) || User::RESERVED.include?(params[:id].downcase)
      head :forbidden
    else
      head :ok
    end
  end
end