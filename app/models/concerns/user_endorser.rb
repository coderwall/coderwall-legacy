module UserEndorser
  extend ActiveSupport::Concern

  def endorsements_unlocked_since_last_visit
    endorsements_since(last_request_at)
  end

  def endorsements_since(since=Time.at(0))
    self.endorsements.where("endorsements.created_at > ?", since).order('endorsements.created_at ASC')
  end

  def endorsers(since=Time.at(0))
    User.where(id: self.endorsements.select('distinct(endorsements.endorsing_user_id), endorsements.created_at').where('endorsements.created_at > ?', since).map(&:endorsing_user_id))
  end

  def endorse(user, specialty)
    user.add_skill(specialty).endorsed_by(self)
  end
end
