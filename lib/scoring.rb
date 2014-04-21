module Scoring
  module HotStream
    def trending_score
      return 0 if flagged?
      (created_at || Time.now).to_i.to_f / (half_life || 1.day).to_i + Math.log2(value_score + 1)
    end
  end

  module HN
    def trending_score
      return 0 if flagged?
      value_score / (((created_at.to_i-Time.parse("05/07/2012").to_i)/60) ** -gravity)
    end
  end
end