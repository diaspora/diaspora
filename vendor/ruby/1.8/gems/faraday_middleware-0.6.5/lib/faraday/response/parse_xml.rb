require 'faraday'

module Faraday
  class Response::ParseXml < Response::Middleware
    dependency 'multi_xml'

    def parse(body)
      ::MultiXml.parse(body)
    end
  end
end
