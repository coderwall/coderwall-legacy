require 'resque_support'
module Awards
  include ResqueSupport::Basic

  def award_from_file(filename)
    text = File.read(filename)
    puts "read #{filename}"
    unless text.nil?
      csv = CSV.parse(text, headers: false)
      csv.each do |row|
        badge = row.shift
        date = row.shift
        provider = row.shift
        row.to_a.each do |candidate|
          Rails.logger.info "award #{badge} to #{candidate}"
          enqueue(Award, badge, date, provider, candidate)
        end
      end
    end
  end

  def award(badge, date, provider, candidate)
    RestClient.post(award_badge_url(only_path: false, host: Rails.application.config.host, protocol: (Rails.application.config.force_ssl ? "https" : "http")), badge: badge, date: date, provider.to_sym => candidate, api_key: ENV['ADMIN_API_KEY'])
  end
end