class SessionsController < ApplicationController
  skip_before_action :require_registration

  # GET                   /sessions/new(.:format)
  def new
    #FIXME
    redirect_to destination_url if signed_in?
  end

  # GET                   /signin(.:format)
  def signin
    #FIXME
    return redirect_to destination_url if signed_in?
    store_location!(params[:return_to]) unless params[:return_to].nil?
  end

  # GET                   /sessions/force(.:format)
  def force
    #REMOVEME
    head(:forbidden) unless Rails.env.development? || current_user.admin?
    sign_out
    user = params[:id].present? ? User.find(params[:id]) : User.find_by_username(params[:username])
    sign_in(user)
    redirect_to(root_url)
  end

  # GET|POST              /auth/:provider/callback(.:format)
  def create
    #FIXME
    raise "OmniAuth returned error #{params[:error]}" unless params[:error].blank?
    if signed_in?
      current_user.apply_oauth(oauth)
      current_user.save!
      flash[:notice] = "#{oauth[:provider].humanize} account linked"
      redirect_to(edit_user_url(current_user))
    else
      @user = User.find_with_oauth(oauth)
      if @user && !@user.new_record?
        sign_in(@user)
        record_event('signed in', via: oauth[:provider])
        return redirect_to(destination_url)
      else
        session["oauth.data"] = oauth
        return redirect_to(new_user_url)
      end
    end
  rescue Faraday::Error::ConnectionFailed => ex
    Rails.logger.error("Faraday::Error::ConnectionFailed => #{ex.message}, #{ex.inspect}")
    record_event("error", message: "attempt to reuse a linked account")
    flash[:error] = "Error linking #{oauth[:info][:nickname]} because it is already associated with a different member."
    redirect_to(root_url)
  rescue ActiveRecord::RecordNotUnique => ex
    record_event("error", message: "attempt to reuse a linked account")
    flash[:error] = "Error linking #{oauth[:info] && oauth[:info][:nickname]} because it is already associated with a different member."
    redirect_to(root_url)
  rescue Exception => ex
    Rails.logger.error("Failed to link account because #{ex.message} => '#{oauth}'")
    record_event("error", message: "signup failure")
    flash[:notice] = "Looks like something went wrong. Please try again."
    redirect_to(root_url)
  end

  # DELETE                /sessions/:id(.:format)
  def destroy
    sign_out
    redirect_to(root_url)
  end

  # GET                   /auth/failure(.:format)
  def failure
    flash[:error] = "Authenication error: #{params[:message].humanize}" unless params[:message].nil?
    render action: :new
  end

  protected

  def oauth
    #FIXME
    @oauth ||= request.env["omniauth.auth"].with_indifferent_access if request.env["omniauth.auth"]
  end
end
