# encoding: utf-8
require 'warden/hooks'
require 'warden/config'

module Warden
  # The middleware for Rack Authentication
  # The middlware requires that there is a session upstream
  # The middleware injects an authentication object into
  # the rack environment hash
  class Manager
    extend Warden::Hooks

    attr_accessor :config

    # Initialize the middleware. If a block is given, a Warden::Config is yielded so you can properly
    # configure the Warden::Manager.
    # :api: public
    def initialize(app, options={})
      default_strategies = options.delete(:default_strategies)

      @app, @config = app, Warden::Config.new(options)
      @config.default_strategies *default_strategies if default_strategies
      yield @config if block_given?
      self
    end

    # Invoke the application guarding for throw :warden.
    # If this is downstream from another warden instance, don't do anything.
    # :api: private
    def call(env) # :nodoc:
      return @app.call(env) if env['warden'] && env['warden'].manager != self

      env['warden'] = Proxy.new(env, self)
      result = catch(:warden) do
        @app.call(env)
      end

      result ||= {}
      case result
      when Array
        if result.first == 401 && intercept_401?(env)
          process_unauthenticated(env)
        else
          result
        end
      when Hash
        process_unauthenticated(env, result)
      end
    end

    # :api: private
    def _run_callbacks(*args) #:nodoc:
      self.class._run_callbacks(*args)
    end

    class << self
      # Prepares the user to serialize into the session.
      # Any object that can be serialized into the session in some way can be used as a "user" object
      # Generally however complex object should not be stored in the session.
      # If possible store only a "key" of the user object that will allow you to reconstitute it.
      #
      # Example:
      #   Warden::Manager.serialize_into_session{ |user| user.id }
      #
      # :api: public
      def serialize_into_session(&block)
        Warden::SessionSerializer.send :define_method, :serialize, &block
      end

      # Reconstitues the user from the session.
      # Use the results of user_session_key to reconstitue the user from the session on requests after the initial login
      #
      # Example:
      #   Warden::Manager.serialize_from_session{ |id| User.get(id) }
      #
      # :api: public
      def serialize_from_session(&block)
        Warden::SessionSerializer.send :define_method, :deserialize, &block
      end
    end

  private

    def intercept_401?(env)
      config[:intercept_401] && !env['warden'].custom_failure?
    end

    # When a request is unauthentiated, here's where the processing occurs.
    # It looks at the result of the proxy to see if it's been executed and what action to take.
    # :api: private
    def process_unauthenticated(env, options={})
      options[:action] ||= "unauthenticated"

      proxy  = env['warden']
      result = options[:result] || proxy.result

      case result
      when :redirect
        body = proxy.message || "You are being redirected to #{proxy.headers['Location']}"
        [proxy.status, proxy.headers, [body]]
      when :custom
        proxy.custom_response
      else
        call_failure_app(env, options)
      end
    end

    # Calls the failure app.
    # The before_failure hooks are run on each failure
    # :api: private
    def call_failure_app(env, options = {})
      if config.failure_app
        options.merge!(:attempted_path => ::Rack::Request.new(env).fullpath)
        env["PATH_INFO"] = "/#{options[:action]}"
        env["warden.options"] = options

        _run_callbacks(:before_failure, env, options)
        config.failure_app.call(env).to_a
      else
        raise "No Failure App provided"
      end
    end # call_failure_app
  end
end # Warden
