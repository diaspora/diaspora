module Jobs
  class HttpPost
    @queue = :http
    def self.perform(url, body, tries_remaining)
      begin
        RestClient.post(url, :xml => body)
      rescue Exception => e
        Resque.enqueue(self, url, body, tries_remaining -1) unless tries_remaining <= 1
        raise e
      end
    end
  end
end
