module Jobs
  class HttpPost
    @queue = :http
    def self.perform(url, body, tries_remaining)
      begin
        RestClient.post(url, body)
      rescue
        Resque.enqueue(self, url, body, tries_remaining -1) unless tries_remaining <= 1
      end
    end
  end
end
