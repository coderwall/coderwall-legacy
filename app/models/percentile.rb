class Percentile
  class << self
    def for(number)
      ranges[number.to_i]
    end

    private
    def ranges
      @ranges ||= Rails.cache.fetch('percentile') do
        hash   = {}
        scores = Team.all.map(&:score).compact.sort
        100.downto(1) do |percent|
          index                 = (scores.length * percent / 100).ceil - 1
          percentile            = scores.sort[index]
          hash[percentile.to_i] = percent
          hash
        end
        hash
      end
    end
  end
end
