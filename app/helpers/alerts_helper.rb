module AlertsHelper

  def alert_data_to_html_for_type(type, data)
    case type
      when :traction
        content_tag(:div, class: 'traction') do
          concat link_to(data[:url], data[:url])
          concat content_tag(:span, data[:message])
        end
      when :google_analytics
        content_tag(:div, class: 'google_analytics') do
          concat content_tag(:span, data[:viewers])
          concat content_tag(:span, class: 'referrers') {
            data[:top_referrers].each do |referrer|
              concat content_tag(:span, referrer)
            end
          }
        end
    end
  end
end