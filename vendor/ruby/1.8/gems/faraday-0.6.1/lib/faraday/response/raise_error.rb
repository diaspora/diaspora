module Faraday
  class Response::RaiseError < Response::Middleware
    def on_complete(env)
      case env[:status]
      when 404
        raise Faraday::Error::ResourceNotFound, response_values(env)
      when 400...600
        raise Faraday::Error::ClientError, response_values(env)
      end
    end
    
    def response_values(env)
      {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
    end
  end
end
