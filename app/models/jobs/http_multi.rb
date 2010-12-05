module Jobs
  class HttpMulti
    @queue = :http

    MAX_RETRIES = 3
    OPTS = {:max_redirects => 3, :timeout => 5000, :method => :post}

    def self.perform(urls, xml, retry_count=0)
      failed_requests = []

      hydra = Typhoeus::Hydra.new
      urls.each do |url|
        request = Typhoeus::Request.new(url, OPTS.merge(:xml => xml))

        request.on_complete do |response|
          unless response.success?
            failed_requests << url
          end
        end

        hydra.queue request
      end
      hydra.run

      unless failed_requests.empty? || retry_count >= MAX_RETRIES
        Resque.enqueue(Jobs::HttpMulti, failed_requests, xml, retry_count+=1 )
      end
    end
  end
end
