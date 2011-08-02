require 'faraday'

module Faraday
  class Response::ParseYaml < Response::Middleware
    dependency 'yaml'

    def parse(body)
      ::YAML.load(body)
    end
  end
end
