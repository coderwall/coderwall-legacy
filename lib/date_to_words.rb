Date.class_eval do
  def to_words
    if self == Date.today
      'today'
    elsif self <= Date.today - 1
      if self == Date.today - 1
        'yesterday'
      elsif ((Date.today - 7)..(Date.today - 1)).include?(self)
        "last #{strftime('%A')}"
      elsif ((Date.today - 14)..(Date.today - 8)).include?(self)
        "two #{strftime('%A')}s ago"
      elsif ((Date.today - 21)..(Date.today - 15)).include?(self)
        "three #{strftime('%A')}s ago"
      elsif ((Date.today - 29)..(Date.today - 22)).include?(self)
        "four #{strftime('%A')}s ago"
      elsif Date.today - 30 < self
        'more than a month ago'
      end
    else
      if self == Date.today + 1
        'tomorrow'
      elsif ((Date.today + 1)..(Date.today + 6)).include?(self)
        "this coming #{strftime('%A')}"
      elsif ((Date.today + 7)..(Date.today + 14)).include?(self)
        "next #{strftime('%A')}"
      elsif ((Date.today + 15)..(Date.today + 21)).include?(self)
        "two #{strftime('%A')}s away"
      elsif ((Date.today + 22)..(Date.today + 29)).include?(self)
        "three #{strftime('%A')}s away"
      elsif Date.today + 30 > self
        'more than a month in the future'
      end
    end
  end
end
