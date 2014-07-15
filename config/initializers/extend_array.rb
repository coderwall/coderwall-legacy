Array.class_eval do
  def chunk(pieces = 2)
    results = []
    counter = 0
    each do |item|
      counter = 0 if counter == pieces
      (results[counter] || (results << Array.new))
      results[counter] << item
      counter = counter + 1
    end
    results
  end
end
