class InvitationsController < ApplicationController

  def show
    @team = Team.find(params[:id])
    invitation_failed! unless @team.has_user_with_referral_token?(params[:r])
    store_location! unless signed_in?
    session[:referred_by] = params[:r]
    record_event("viewed", what: "invitation")
  rescue Mongoid::Errors::DocumentNotFound
    invitation_failed!
  end

  private
  def invitation_failed!
    flash[:notice] = "Sorry, that invitation is no longer valid."
    record_event("error", message: "invitation failure")
    redirect_to(root_url)
  end
end