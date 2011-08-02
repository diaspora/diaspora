module Faraday
  class Middleware
    class << self
      attr_accessor :load_error, :supports_parallel_requests
      alias supports_parallel_requests? supports_parallel_requests

      # valid parallel managers should respond to #run with no parameters.
      # otherwise, return a short wrapper around it.
      def setup_parallel_manager(options = {})
        nil
      end
    end

    # Executes a block which should try to require and reference dependent libraries
    def self.dependency(lib = nil)
      lib ? require(lib) : yield
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def self.loaded?
      @load_error.nil?
    end

    def initialize(app = nil)
      @app = app
    end
  end
end