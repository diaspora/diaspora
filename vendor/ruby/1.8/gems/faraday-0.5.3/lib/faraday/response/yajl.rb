module Faraday
  class Response::Yajl < Response::Middleware
    begin
      require 'yajl'

      def self.register_on_complete(env)
        env[:response].on_complete do |finished_env|
          finished_env[:body] = parse(finished_env[:body])
        end
      end
    rescue LoadError, NameError => e
      self.load_error = e
    end

    def initialize(app)
      super
      @parser = nil
    end

    def self.parse(body)
      Yajl::Parser.parse(body)
    rescue Object => err
      raise Faraday::Error::ParsingError.new(err)
    end
  end
end
