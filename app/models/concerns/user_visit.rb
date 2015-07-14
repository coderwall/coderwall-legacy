module UserVisit
  extend ActiveSupport::Concern

  def visited!
    self.append_latest_visits(Time.now) if self.last_request_at && (self.last_request_at < 1.day.ago)
    self.touch(:last_request_at)
  end

  def latest_visits
    @latest_visits ||= self.visits.split(";").map(&:to_time)
  end

  def append_latest_visits(timestamp)
    self.visits = (self.visits.split(";") << timestamp.to_s).join(";")
    self.visits.slice!(0, self.visits.index(';')+1) if self.visits.length >= 64
    calculate_frequency_of_visits!
  end

  def average_time_between_visits
    @average_time_between_visits ||= (self.latest_visits.each_with_index.map { |visit, index| visit - self.latest_visits[index-1] }.reject { |difference| difference < 0 }.reduce(:+) || 0)/self.latest_visits.count
  end

  def calculate_frequency_of_visits!
    self.visit_frequency = begin
      if average_time_between_visits < 2.days
        :daily
      elsif average_time_between_visits < 10.days
        :weekly
      elsif average_time_between_visits < 40.days
        :monthly
      else
        :rarely
      end
    end
  end

  def activity_since_last_visit?
    (achievements_unlocked_since_last_visit.count + endorsements_unlocked_since_last_visit.count) > 0
  end
end
