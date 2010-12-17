module Jobs
  class HttpPost
    extend ResqueJobLogging
    @queue = :http

    def self.perform(url, body, tries_remaining)
      begin
        RestClient.post(url, :xml => body){ |response, request, result, &block|
          if [301, 302, 307].include? response.code
            response.follow_redirection(request, result, &block)
          else
            response.return!(request, result, &block)
          end
        }
      rescue Exception => e
        unless tries_remaining <= 1
          Resque.enqueue(self, url, body, tries_remaining -1)
        else
          raise e
        end
      end
    end
  end
end
