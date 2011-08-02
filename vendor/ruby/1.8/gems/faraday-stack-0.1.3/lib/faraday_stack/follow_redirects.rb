module FaradayStack
  class RedirectLimitReached < Faraday::Error::ClientError
    attr_reader :response
    
    def initialize(response)
      super "too many redirects; last one to: #{response['location']}"
      @response = response
    end
  end
  
  class FollowRedirects < Faraday::Middleware
    # TODO: 307
    REDIRECTS = [301, 302, 303]
    # default value for max redirects followed
    FOLLOW_LIMIT = 3
    
    def initialize(app, options = {})
      super(app)
      @options = options
      @follow_limit = options[:limit] || FOLLOW_LIMIT
    end
    
    def call(env)
      process_response(@app.call(env), @follow_limit)
    end
    
    def process_response(response, follows)
      response.on_complete do |env|
        if redirect? response
          raise RedirectLimitReached, response if follows.zero?
          env[:url] += response['location']
          env[:method] = :get
          response = process_response(@app.call(env), follows - 1)
        end
      end
      response
    end
    
    def redirect?(response)
      REDIRECTS.include? response.status
    end
  end
end
