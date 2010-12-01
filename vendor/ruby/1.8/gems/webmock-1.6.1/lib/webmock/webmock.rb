module WebMock

  def self.included(clazz)
    WebMock::Deprecation.warning("include WebMock is deprecated. Please include WebMock::API instead")
    if clazz.instance_methods.map(&:to_s).include?('request')
      warn "WebMock#request was not included in #{clazz} to avoid name collision"
    else
      clazz.class_eval do
        def request(method, uri)
          WebMock::Deprecation.warning("WebMock#request is deprecated. Please use WebMock::API#a_request method instead")
          WebMock.a_request(method, uri)
        end
      end
    end
  end

  include WebMock::API
  extend WebMock::API

  class << self
    alias :request :a_request
  end

  def self.version
    open(File.join(File.dirname(__FILE__), '../../VERSION')) { |f|
      f.read.strip
    }
  end

  def self.allow_net_connect!(options = {})
    Config.instance.allow_net_connect = true
    Config.instance.net_http_connect_on_start = options[:net_http_connect_on_start]
  end

  def self.disable_net_connect!(options = {})
    Config.instance.allow_net_connect = false
    Config.instance.allow_localhost = options[:allow_localhost]
    Config.instance.allow = options[:allow]
    Config.instance.net_http_connect_on_start = options[:net_http_connect_on_start]
  end

  def self.net_connect_allowed?(uri = nil)
    if uri.is_a?(String)
      uri = WebMock::Util::URI.normalize_uri(uri)
    end
    Config.instance.allow_net_connect ||
      (Config.instance.allow_localhost && WebMock::Util::URI.is_uri_localhost?(uri)) ||
      Config.instance.allow && Config.instance.allow.include?(uri.host)
  end

  def self.reset!
    WebMock::RequestRegistry.instance.reset!
    WebMock::StubRegistry.instance.reset!
  end
  
  def self.reset_webmock
    WebMock::Deprecation.warning("WebMock.reset_webmock is deprecated. Please use WebMock.reset! method instead")
    reset!
  end
  
  def self.reset_callbacks
    WebMock::CallbackRegistry.reset
  end

  def self.after_request(options={}, &block)
    WebMock::CallbackRegistry.add_callback(options, block)
  end

  def self.registered_request?(request_signature)
    WebMock::StubRegistry.instance.registered_request?(request_signature)
  end

  def self.print_executed_requests
    puts WebMock::RequestExecutionVerifier.executed_requests_message
  end

  %w(
    allow_net_connect!
    disable_net_connect!
    net_connect_allowed?
    reset_webmock
    reset_callbacks
    after_request
    registered_request?
  ).each do |method|
    self.class_eval(%Q(
      def #{method}(*args, &block)
        WebMock::Deprecation.warning("WebMock##{method} instance method is deprecated. Please use WebMock.#{method} class method instead")
        WebMock.#{method}(*args, &block)
      end
    ))
  end

end
