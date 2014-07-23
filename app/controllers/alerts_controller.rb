class AlertsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :get_alert, only: :create
  before_action :authenticate_caller, only: :create
  before_action :is_admin?, only: :index

  GA_VISITORS_ALERT_INTERVAL = 30.minutes
  TRACTION_ALERT_INTERVAL    = 30.minutes

  def create
    case @alert[:type].to_sym
      when :traction
        process_traction_alert(@alert[:data])
      when :google_analytics
        process_google_analytics(@alert[:data])
    end
    update_stats
    head(:ok)
  end

  def index
    @alerts = []
    [:traction, :google_analytics].each do |type|
      count = Redis.current.get(count_key(type))
      next if count.nil?
      @alerts << { type: type, count: count, data: Redis.current.zrangebyscore(history_key(type), 0, Time.now.to_i, withscores: true) }
    end
  end

  private

  def authenticate_caller
    valid = true

    case @alert[:type].to_sym
      when :traction, :google_analytics
        valid = (@alert[:key] == "3fEtu89_W13k1")
      else
        valid = false
    end
    return head(:forbidden) unless valid
  end

  def get_alert
    @alert = JSON.parse(request.body.read).with_indifferent_access
  end

  def process_traction_alert(data)
    if can_report_traction?(data[:url])
      update_history
      Redis.current.set(last_sent_key(:traction, data[:url]), Time.now.to_i)
      Notifier.alert_admin(:traction, data[:url], data[:message]).deliver
    end
  end

  def process_google_analytics(data)
    message = "#{data[:viewers]} viewers on site"
    message += "\ntop referrers:#{data[:top_referrers].join("\n")}"

    if can_report_visitors?
      if data[:viewers] > ENV['SITE_VISITORS_MAX_ALERT_LIMIT']
        update_history
        Redis.current.set(last_sent_key(:google_analytics), Time.now.to_i)
        Notifier.alert_admin(:a_lot_of_visitors, data[:url], message).deliver!
      elsif data[:viewers] < ENV['SITE_VISITORS_MIN_ALERT_LIMIT']
        update_history
        Redis.current.set(last_sent_key(:google_analytics), Time.now.to_i)
        Notifier.alert_admin(:too_few_visitors, data[:url], message).deliver!
      end
    end
  end

  def can_report_visitors?
    Time.at(Redis.current.get(last_sent_key(:google_analytics)).to_i) < GA_VISITORS_ALERT_INTERVAL.ago
  end

  def can_report_traction?(url)
    Time.at(Redis.current.get(last_sent_key(:traction, url)).to_i) < TRACTION_ALERT_INTERVAL.ago
  end

  def last_sent_key(type, subkey=nil)
    key = "alert:#{type}:last_sent"
    key += ":#{subkey}" unless subkey.nil?
    key
  end

  def count_key(type)
    "alert:#{type}:count"
  end

  def history_key(type)
    "alert:#{type}:history"
  end

  def update_stats
    Redis.current.incr(count_key(@alert[:type]))
  end

  def update_history
    Redis.current.zadd(history_key(@alert[:type]), Time.now.to_i, @alert[:data])
  end
end