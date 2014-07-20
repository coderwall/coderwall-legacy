class Servant
  class << self
    def reset_counter!
      @counter = 0
    end

    def increment!
      @counter &&= @counter + 1
    end

    def capture_api_calls
      reset_counter!
      yield
      @counter
    end

    def get(url)
      increment!
      response = RestClient.get(url, verify_ssl: false)
      response = ServiceResponse.new(response.to_s, response.headers)
      return response
    end
  end
end
