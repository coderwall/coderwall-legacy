module AdminHelper
  def midnight
    DateTime.now.in_time_zone("Pacific Time (US & Canada)").midnight
  end
  def signups_y
    User.where("created_at > ? AND created_at <= ?", midnight - 1.day, midnight).count
  end
  def signups_t
    User.where("created_at > ?", midnight).count
  end
  def referred_signups_y
    User.where('referred_by IS NOT NULL').where("created_at > ? AND created_at <= ?", midnight - 1.day, midnight).count
  end
  def referred_signups_t
    User.where('referred_by IS NOT NULL').where("created_at > ? ", midnight).count
  end
  def visited_y
    User.active.where("last_request_at > ? AND last_request_at <= ?", midnight - 1.day, midnight).count
  end
  def visited_t
    User.active.where("last_request_at > ?", midnight).count
  end
  def protips_created_y
    Protip.where("created_at > ? AND created_at <= ?", midnight - 1.day, midnight).count
  end
  def protips_created_t
    Protip.where("created_at > ?", midnight).count
  end
  def original_protips_created_y
    Protip.where("created_at > ? AND created_at <= ?", midnight - 1.day, midnight).reject(&:created_automagically?).count
  end
  def original_protips_created_t
    Protip.where("created_at > ?", midnight).reject(&:created_automagically?).count
  end
  def protip_upvotes_y
    Like.where(:likable_type => "Protip").where("created_at > ? AND created_at <= ?", midnight - 1.day, midnight).count
  end
  def protip_upvotes_t
    Like.where(:likable_type => "Protip").where("created_at > ?", midnight).count
  end
  def mau_l
    User.where("last_request_at >= ? AND last_request_at < ?", 2.months.ago, 31.days.ago).count
  end
  def mau_minus_new_signups_l
    User.where("last_request_at >= ? AND last_request_at < ? AND created_at < ?", 2.months.ago, 31.days.ago, 2.months.ago).count
  end
  def mau_t
    User.where("last_request_at >= ?", 31.days.ago).count
  end
  def mau_minus_new_signups_t
    User.where("last_request_at >= ? AND created_at < ?", 31.days.ago, 31.days.ago).count
  end
end