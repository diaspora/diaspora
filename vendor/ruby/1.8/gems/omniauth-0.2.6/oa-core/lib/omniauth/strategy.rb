require 'omniauth/core'

module OmniAuth
  class NoSessionError < StandardError; end
  # The Strategy is the base unit of OmniAuth's ability to
  # wrangle multiple providers. Each strategy provided by
  # OmniAuth includes this mixin to gain the default functionality
  # necessary to be compatible with the OmniAuth library.
  module Strategy
    def self.included(base)
      OmniAuth.strategies << base
      base.class_eval do
        attr_reader :app, :name, :env, :options, :response
      end
    end

    def initialize(app, name, *args, &block)
      @app = app
      @name = name.to_sym
      @options = args.last.is_a?(Hash) ? args.pop : {}

      yield self if block_given?
    end

    def inspect
      "#<#{self.class.to_s}>"
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      raise OmniAuth::NoSessionError.new("You must provide a session to use OmniAuth.") unless env['rack.session']

      @env = env
      @env['omniauth.strategy'] = self if on_auth_path?

      return mock_call!(env) if OmniAuth.config.test_mode

      return request_call if on_request_path? && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
      return callback_call if on_callback_path?
      return other_phase if respond_to?(:other_phase)
      @app.call(env)
    end

    # Performs the steps necessary to run the request phase of a strategy.
    def request_call
      setup_phase
      if response = call_through_to_app
        response
      else
        if request.params['origin']
          @env['rack.session']['omniauth.origin'] = request.params['origin']
        elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
          @env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
        end
        request_phase
      end
    end

    # Performs the steps necessary to run the callback phase of a strategy.
    def callback_call
      setup_phase
      @env['omniauth.origin'] = session.delete('omniauth.origin')
      @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''

      callback_phase
    end

    def on_auth_path?
      on_request_path? || on_callback_path?
    end

    def on_request_path?
      current_path.casecmp(request_path) == 0
    end

    def on_callback_path?
      current_path.casecmp(callback_path) == 0
    end

    def mock_call!(env)
      return mock_request_call if on_request_path?
      return mock_callback_call if on_callback_path?
      call_app!
    end

    def mock_request_call
      setup_phase
      return response if response = call_through_to_app

      if request.params['origin']
        @env['rack.session']['omniauth.origin'] = request.params['origin']
      elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
        @env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
      end
      redirect(script_name + callback_path)
    end

    def mock_callback_call
      setup_phase
      mocked_auth = OmniAuth.mock_auth_for(name.to_sym)
      if mocked_auth.is_a?(Symbol)
        fail!(mocked_auth)
      else
        @env['omniauth.auth'] = mocked_auth
        @env['omniauth.origin'] = session.delete('omniauth.origin')
        @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
        call_app!
      end
    end

    def setup_phase
      if options[:setup].respond_to?(:call)
        options[:setup].call(env)
      elsif options[:setup]
        setup_env = env.merge('PATH_INFO' => setup_path, 'REQUEST_METHOD' => 'GET')
        call_app!(setup_env)
      end
    end

    def request_phase
      raise NotImplementedError
    end

    def callback_phase
      @env['omniauth.auth'] = auth_hash
      call_app!
    end

    def path_prefix
      options[:path_prefix] || OmniAuth.config.path_prefix
    end

    def request_path
      options[:request_path] || "#{path_prefix}/#{name}"
    end

    def callback_path
      options[:callback_path] || "#{path_prefix}/#{name}/callback"
    end

    def setup_path
      options[:setup_path] || "#{path_prefix}/#{name}/setup"
    end

    def current_path
      request.path_info.downcase.sub(/\/$/,'')
    end

    def query_string
      request.query_string.empty? ? "" : "?#{request.query_string}"
    end

    def call_through_to_app
      status, headers, body = *call_app!
      @response = Rack::Response.new(body, status, headers)

      status == 404 ? nil : @response.finish
    end

    def call_app!(env = @env)
      @app.call(env)
    end

    def auth_hash
      {
        'provider' => name.to_s,
        'uid' => nil
      }
    end

    def full_host
      case OmniAuth.config.full_host
        when String
          OmniAuth.config.full_host
        when Proc
          OmniAuth.config.full_host.call(env)
        else
          uri = URI.parse(request.url.gsub(/\?.*$/,''))
          uri.path = ''
          uri.query = nil
          uri.to_s
      end
    end

    def callback_url
      full_host + script_name + callback_path + query_string
    end

    def script_name
      @env['SCRIPT_NAME'] || ''
    end

    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def redirect(uri)
      r = Rack::Response.new

      if options[:iframe]
        r.write("<script type='text/javascript' charset='utf-8'>top.location.href = '#{uri}';</script>")
      else
        r.write("Redirecting to #{uri}...")
        r.redirect(uri)
      end

      r.finish
    end

    def user_info; {} end

    def fail!(message_key, exception = nil)
      self.env['omniauth.error'] = exception
      self.env['omniauth.error.type'] = message_key.to_sym
      self.env['omniauth.error.strategy'] = self

      OmniAuth.config.on_failure.call(self.env)
    end
  end
end
