module Faraday
  class Response
    class Middleware < Faraday::Middleware
      self.load_error = :abstract

      # Use a response callback in case the request is parallelized.
      #
      #   env[:response].on_complete do |finished_env|
      #     finished_env[:body] = do_stuff_to(finished_env[:body])
      #   end
      #
      def self.register_on_complete(env)
      end

      def call(env)
        self.class.register_on_complete(env)
        @app.call env
      end
    end

    extend AutoloadHelper

    autoload_all 'faraday/response',
      :Yajl              => 'yajl',
      :ActiveSupportJson => 'active_support_json'

    register_lookup_modules \
      :yajl                => :Yajl,
      :activesupport_json  => :ActiveSupportJson,
      :rails_json          => :ActiveSupportJson,
      :active_support_json => :ActiveSupportJson
    attr_accessor :status, :headers, :body

    def initialize
      @status, @headers, @body = nil, nil, nil
      @on_complete_callbacks = []
    end

    def on_complete(&block)
      @on_complete_callbacks << block
    end

    def finish(env)
      env[:body] ||= ''
      @on_complete_callbacks.each { |c| c.call(env) }
      @status, @headers, @body = env[:status], env[:response_headers], env[:body]
      self
    end

    def success?
      status == 200
    end
  end
end
