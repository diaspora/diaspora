module Faraday
  class Response::ActiveSupportJson < Response::Middleware
    begin
      if !defined?(ActiveSupport::JSON)
        require 'active_support'
        ActiveSupport::JSON
      end

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
      ActiveSupport::JSON.decode(body)
    rescue Object => err
      raise Faraday::Error::ParsingError.new(err)
    end
  end
end
