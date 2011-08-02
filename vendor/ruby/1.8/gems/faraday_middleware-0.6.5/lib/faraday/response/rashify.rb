require 'faraday'

module Faraday
  class Response::Rashify < Response::Middleware
    dependency 'hashie/mash'
    dependency 'rash'

    def parse(body)
      case body
      when Hash
        ::Hashie::Rash.new(body)
      when Array
        body.map { |item| item.is_a?(Hash) ? ::Hashie::Rash.new(item) : item }
      else
        body
      end
    end
  end
end
