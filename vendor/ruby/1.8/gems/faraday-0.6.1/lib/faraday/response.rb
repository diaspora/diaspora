require 'forwardable'

module Faraday
  class Response
    # Used for simple response middleware.
    class Middleware < Faraday::Middleware
      def call(env)
        @app.call(env).on_complete do |env|
          on_complete(env)
        end
      end

      # Override this to modify the environment after the response has finished.
      # Calls the `parse` method if defined
      def on_complete(env)
        if respond_to? :parse
          env[:body] = parse(env[:body])
        end
      end
    end

    extend Forwardable
    extend AutoloadHelper

    autoload_all 'faraday/response',
      :RaiseError => 'raise_error',
      :Logger     => 'logger'

    register_lookup_modules \
      :raise_error => :RaiseError,
      :logger      => :Logger

    def initialize(env = nil)
      @env = env
      @on_complete_callbacks = []
    end

    attr_reader :env
    alias_method :to_hash, :env

    def status
      finished? ? env[:status] : nil
    end

    def headers
      finished? ? env[:response_headers] : {}
    end
    def_delegator :headers, :[]

    def body
      finished? ? env[:body] : nil
    end

    def finished?
      !!env
    end

    def on_complete
      if not finished?
        @on_complete_callbacks << Proc.new
      else
        yield env
      end
      return self
    end

    def finish(env)
      raise "response already finished" if finished?
      @env = env
      @on_complete_callbacks.each { |callback| callback.call(env) }
      return self
    end

    def success?
      status == 200
    end

    # because @on_complete_callbacks cannot be marshalled
    def marshal_dump
      !finished? ? nil : {
        :status => @env[:status], :body => @env[:body],
        :response_headers => @env[:response_headers]
      }
    end

    def marshal_load(env)
      @env = env
    end

    # Expand the env with more properties, without overriding existing ones.
    # Useful for applying request params after restoring a marshalled Response.
    def apply_request(request_env)
      raise "response didn't finish yet" unless finished?
      @env = request_env.merge @env
      return self
    end
  end
end
