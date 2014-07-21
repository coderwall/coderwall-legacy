class ActivateUser < RefreshUser
  @queue = 'HIGH'

  attr_reader :always_activate

  def initialize(user_id, always_activate = true)
    super(user_id)
    @always_activate = always_activate
  end

  def perform
    return if @user.active?
    refresh!
    if activate_user?(@user)
      user.activate!
      Notifier.welcome_email(@user.username).deliver
    end
  end

  def activate_user?(user)
    return true if !user.badges.empty?
    always_activate
  end

end
