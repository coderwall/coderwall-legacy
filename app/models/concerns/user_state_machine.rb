module UserStateMachine
  extend ActiveSupport::Concern

  def activate
    UserActivateWorker.perform_async(id)
  end

  def activate!
    # TODO: Switch to update, failing validations?
    update_attributes!(state: User::ACTIVE, activated_on: DateTime.now)
  end

  def unregistered?
    state == nil
  end

  def not_active?
    !active?
  end

  def active?
    state == User::ACTIVE
  end

  def pending?
    state == User::PENDING
  end

  def banned?
    banned_at.present?
  end

  def complete_registration!
    update_attribute(:state, User::PENDING)
    activate
  end
end