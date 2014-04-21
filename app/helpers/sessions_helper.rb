module SessionsHelper

  def failed_signin?
    params[:action] == 'failure'
  end

  def user_was_invited?
    @invitation.present?
  end

end