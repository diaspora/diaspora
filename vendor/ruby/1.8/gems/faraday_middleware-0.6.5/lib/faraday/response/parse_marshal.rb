require 'faraday'

module Faraday
  class Response::ParseMarshal < Response::Middleware

    def parse(body)
      ::Marshal.load(body)
    end
  end
end
