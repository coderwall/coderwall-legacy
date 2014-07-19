class ActivateUser < RefreshUser
  @queue = 'HIGH'

  attr_reader :always_activate

  def initialize(username, always_activate=true)
    super(username)
    @always_activate = always_activate
  end

  def perform
    user = User.find_by_username(username)
    return if user.active?
    refresh!
    if activate_user?(user)
      user.activate!
      Notifier.welcome_email(username).deliver
    end
  end

  def activate_user?(user)
    return true if !user.badges.empty?
    always_activate
  end

end
