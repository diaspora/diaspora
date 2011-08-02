require 'faraday'

module Faraday
  class Response::ParseJson < Response::Middleware
    dependency 'multi_json'

    def parse(body)
      case body
      when ''
        nil
      when 'true'
        true
      when 'false'
        false
      else
        ::MultiJson.decode(body)
      end
    end
  end
end
