require 'stringio'
require 'uri'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/object/try'
require 'rack/test'
require 'test/unit/assertions'

module ActionDispatch
  module Integration #:nodoc:
    module RequestHelpers
      # Performs a GET request with the given parameters.
      #
      # - +path+: The URI (as a String) on which you want to perform a GET
      #   request.
      # - +parameters+: The HTTP parameters that you want to pass. This may
      #   be +nil+,
      #   a Hash, or a String that is appropriately encoded
      #   (<tt>application/x-www-form-urlencoded</tt> or
      #   <tt>multipart/form-data</tt>).
      # - +headers+: Additional HTTP headers to pass, as a Hash. The keys will
      #   automatically be upcased, with the prefix 'HTTP_' added if needed.
      #
      # This method returns an Response object, which one can use to
      # inspect the details of the response. Furthermore, if this method was
      # called from an ActionDispatch::IntegrationTest object, then that
      # object's <tt>@response</tt> instance variable will point to the same
      # response object.
      #
      # You can also perform POST, PUT, DELETE, and HEAD requests with +post+,
      # +put+, +delete+, and +head+.
      def get(path, parameters = nil, headers = nil)
        process :get, path, parameters, headers
      end

      # Performs a POST request with the given parameters. See get() for more
      # details.
      def post(path, parameters = nil, headers = nil)
        process :post, path, parameters, headers
      end

      # Performs a PUT request with the given parameters. See get() for more
      # details.
      def put(path, parameters = nil, headers = nil)
        process :put, path, parameters, headers
      end

      # Performs a DELETE request with the given parameters. See get() for
      # more details.
      def delete(path, parameters = nil, headers = nil)
        process :delete, path, parameters, headers
      end

      # Performs a HEAD request with the given parameters. See get() for more
      # details.
      def head(path, parameters = nil, headers = nil)
        process :head, path, parameters, headers
      end

      # Performs an XMLHttpRequest request with the given parameters, mirroring
      # a request from the Prototype library.
      #
      # The request_method is :get, :post, :put, :delete or :head; the
      # parameters are +nil+, a hash, or a url-encoded or multipart string;
      # the headers are a hash.  Keys are automatically upcased and prefixed
      # with 'HTTP_' if not already.
      def xml_http_request(request_method, path, parameters = nil, headers = nil)
        headers ||= {}
        headers['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
        headers['HTTP_ACCEPT'] ||= [Mime::JS, Mime::HTML, Mime::XML, 'text/xml', Mime::ALL].join(', ')
        process(request_method, path, parameters, headers)
      end
      alias xhr :xml_http_request

      # Follow a single redirect response. If the last response was not a
      # redirect, an exception will be raised. Otherwise, the redirect is
      # performed on the location header.
      def follow_redirect!
        raise "not a redirect! #{status} #{status_message}" unless redirect?
        get(response.location)
        status
      end

      # Performs a request using the specified method, following any subsequent
      # redirect. Note that the redirects are followed until the response is
      # not a redirect--this means you may run into an infinite loop if your
      # redirect loops back to itself.
      def request_via_redirect(http_method, path, parameters = nil, headers = nil)
        process(http_method, path, parameters, headers)
        follow_redirect! while redirect?
        status
      end

      # Performs a GET request, following any subsequent redirect.
      # See +request_via_redirect+ for more information.
      def get_via_redirect(path, parameters = nil, headers = nil)
        request_via_redirect(:get, path, parameters, headers)
      end

      # Performs a POST request, following any subsequent redirect.
      # See +request_via_redirect+ for more information.
      def post_via_redirect(path, parameters = nil, headers = nil)
        request_via_redirect(:post, path, parameters, headers)
      end

      # Performs a PUT request, following any subsequent redirect.
      # See +request_via_redirect+ for more information.
      def put_via_redirect(path, parameters = nil, headers = nil)
        request_via_redirect(:put, path, parameters, headers)
      end

      # Performs a DELETE request, following any subsequent redirect.
      # See +request_via_redirect+ for more information.
      def delete_via_redirect(path, parameters = nil, headers = nil)
        request_via_redirect(:delete, path, parameters, headers)
      end
    end

    # An integration Session instance represents a set of requests and responses
    # performed sequentially by some virtual user. Because you can instantiate
    # multiple sessions and run them side-by-side, you can also mimic (to some
    # limited extent) multiple simultaneous users interacting with your system.
    #
    # Typically, you will instantiate a new session using
    # IntegrationTest#open_session, rather than instantiating
    # Integration::Session directly.
    class Session
      DEFAULT_HOST = "www.example.com"

      include Test::Unit::Assertions
      include TestProcess, RequestHelpers, Assertions

      %w( status status_message headers body redirect? ).each do |method|
        delegate method, :to => :response, :allow_nil => true
      end

      %w( path ).each do |method|
        delegate method, :to => :request, :allow_nil => true
      end

      # The hostname used in the last request.
      def host
        @host || DEFAULT_HOST
      end
      attr_writer :host

      # The remote_addr used in the last request.
      attr_accessor :remote_addr

      # The Accept header to send.
      attr_accessor :accept

      # A map of the cookies returned by the last response, and which will be
      # sent with the next request.
      def cookies
        _mock_session.cookie_jar
      end

      # A reference to the controller instance used by the last request.
      attr_reader :controller

      # A reference to the request instance used by the last request.
      attr_reader :request

      # A reference to the response instance used by the last request.
      attr_reader :response

      # A running counter of the number of requests processed.
      attr_accessor :request_count

      include ActionDispatch::Routing::UrlFor

      # Create and initialize a new Session instance.
      def initialize(app)
        @app = app

        # If the app is a Rails app, make url_helpers available on the session
        # This makes app.url_for and app.foo_path available in the console
        if app.respond_to?(:routes) && app.routes.respond_to?(:url_helpers)
          singleton_class.class_eval { include app.routes.url_helpers }
        end

        reset!
      end

      def default_url_options
        { :host => host, :protocol => https? ? "https" : "http" }
      end

      # Resets the instance. This can be used to reset the state information
      # in an existing session instance, so it can be used from a clean-slate
      # condition.
      #
      #   session.reset!
      def reset!
        @https = false
        @controller = @request = @response = nil
        @_mock_session = nil
        @request_count = 0

        self.host        = DEFAULT_HOST
        self.remote_addr = "127.0.0.1"
        self.accept      = "text/xml,application/xml,application/xhtml+xml," +
                           "text/html;q=0.9,text/plain;q=0.8,image/png," +
                           "*/*;q=0.5"

        unless defined? @named_routes_configured
          # install the named routes in this session instance.
          klass = singleton_class

          # the helpers are made protected by default--we make them public for
          # easier access during testing and troubleshooting.
          @named_routes_configured = true
        end
      end

      # Specify whether or not the session should mimic a secure HTTPS request.
      #
      #   session.https!
      #   session.https!(false)
      def https!(flag = true)
        @https = flag
      end

      # Return +true+ if the session is mimicking a secure HTTPS request.
      #
      #   if session.https?
      #     ...
      #   end
      def https?
        @https
      end

      # Set the host name to use in the next request.
      #
      #   session.host! "www.example.com"
      def host!(name)
        @host = name
      end

      private
        def _mock_session
          @_mock_session ||= Rack::MockSession.new(@app, host)
        end

        # Performs the actual request.
        def process(method, path, parameters = nil, rack_environment = nil)
          if path =~ %r{://}
            location = URI.parse(path)
            https! URI::HTTPS === location if location.scheme
            host! location.host if location.host
            path = location.query ? "#{location.path}?#{location.query}" : location.path
          end

          unless ActionController::Base < ActionController::Testing
            ActionController::Base.class_eval do
              include ActionController::Testing
            end
          end

          env = {
            :method => method,
            :params => parameters,

            "SERVER_NAME"     => host.split(':')[0],
            "SERVER_PORT"     => (https? ? "443" : "80"),
            "HTTPS"           => https? ? "on" : "off",
            "rack.url_scheme" => https? ? "https" : "http",

            "REQUEST_URI"    => path,
            "HTTP_HOST"      => host,
            "REMOTE_ADDR"    => remote_addr,
            "CONTENT_TYPE"   => "application/x-www-form-urlencoded",
            "HTTP_ACCEPT"    => accept
          }

          session = Rack::Test::Session.new(_mock_session)

          (rack_environment || {}).each do |key, value|
            env[key] = value
          end

          # NOTE: rack-test v0.5 doesn't build a default uri correctly
          # Make sure requested path is always a full uri
          uri = URI.parse('/')
          uri.scheme ||= env['rack.url_scheme']
          uri.host   ||= env['SERVER_NAME']
          uri.port   ||= env['SERVER_PORT'].try(:to_i)
          uri += path

          session.request(uri.to_s, env)

          @request_count += 1
          @request  = ActionDispatch::Request.new(session.last_request.env)
          response = _mock_session.last_response
          @response = ActionDispatch::TestResponse.new(response.status, response.headers, response.body)
          @html_document = nil

          @controller = session.last_request.env['action_controller.instance']

          return response.status
        end
    end

    module Runner
      include ActionDispatch::Assertions

      def app
        @app
      end

      # Reset the current session. This is useful for testing multiple sessions
      # in a single test case.
      def reset!
        @integration_session = Integration::Session.new(app)
      end

      %w(get post put head delete cookies assigns
         xml_http_request xhr get_via_redirect post_via_redirect).each do |method|
        define_method(method) do |*args|
          reset! unless @integration_session
          # reset the html_document variable, but only for new get/post calls
          @html_document = nil unless %w(cookies assigns).include?(method)
          @integration_session.__send__(method, *args).tap do
            copy_session_variables!
          end
        end
      end

      # Open a new session instance. If a block is given, the new session is
      # yielded to the block before being returned.
      #
      #   session = open_session do |sess|
      #     sess.extend(CustomAssertions)
      #   end
      #
      # By default, a single session is automatically created for you, but you
      # can use this method to open multiple sessions that ought to be tested
      # simultaneously.
      def open_session(app = nil)
        dup.tap do |session|
          yield session if block_given?
        end
      end

      # Copy the instance variables from the current session instance into the
      # test instance.
      def copy_session_variables! #:nodoc:
        return unless @integration_session
        %w(controller response request).each do |var|
          instance_variable_set("@#{var}", @integration_session.__send__(var))
        end
      end

      extend ActiveSupport::Concern
      include ActionDispatch::Routing::UrlFor

      def url_options
        reset! unless @integration_session
        @integration_session.url_options
      end

      # Delegate unhandled messages to the current session instance.
      def method_missing(sym, *args, &block)
        reset! unless @integration_session
        if @integration_session.respond_to?(sym)
          @integration_session.__send__(sym, *args, &block).tap do
            copy_session_variables!
          end
        else
          super
        end
      end
    end
  end

  # An IntegrationTest is one that spans multiple controllers and actions,
  # tying them all together to ensure they work together as expected. It tests
  # more completely than either unit or functional tests do, exercising the
  # entire stack, from the dispatcher to the database.
  #
  # At its simplest, you simply extend IntegrationTest and write your tests
  # using the get/post methods:
  #
  #   require "test_helper"
  #
  #   class ExampleTest < ActionController::IntegrationTest
  #     fixtures :people
  #
  #     def test_login
  #       # get the login page
  #       get "/login"
  #       assert_equal 200, status
  #
  #       # post the login and follow through to the home page
  #       post "/login", :username => people(:jamis).username,
  #         :password => people(:jamis).password
  #       follow_redirect!
  #       assert_equal 200, status
  #       assert_equal "/home", path
  #     end
  #   end
  #
  # However, you can also have multiple session instances open per test, and
  # even extend those instances with assertions and methods to create a very
  # powerful testing DSL that is specific for your application. You can even
  # reference any named routes you happen to have defined!
  #
  #   require "test_helper"
  #
  #   class AdvancedTest < ActionController::IntegrationTest
  #     fixtures :people, :rooms
  #
  #     def test_login_and_speak
  #       jamis, david = login(:jamis), login(:david)
  #       room = rooms(:office)
  #
  #       jamis.enter(room)
  #       jamis.speak(room, "anybody home?")
  #
  #       david.enter(room)
  #       david.speak(room, "hello!")
  #     end
  #
  #     private
  #
  #       module CustomAssertions
  #         def enter(room)
  #           # reference a named route, for maximum internal consistency!
  #           get(room_url(:id => room.id))
  #           assert(...)
  #           ...
  #         end
  #
  #         def speak(room, message)
  #           xml_http_request "/say/#{room.id}", :message => message
  #           assert(...)
  #           ...
  #         end
  #       end
  #
  #       def login(who)
  #         open_session do |sess|
  #           sess.extend(CustomAssertions)
  #           who = people(who)
  #           sess.post "/login", :username => who.username,
  #             :password => who.password
  #           assert(...)
  #         end
  #       end
  #   end
  class IntegrationTest < ActiveSupport::TestCase
    include Integration::Runner
    include ActionController::TemplateAssertions

    @@app = nil

    def self.app
      # DEPRECATE Rails application fallback
      # This should be set by the initializer
      @@app || (defined?(Rails.application) && Rails.application) || nil
    end

    def self.app=(app)
      @@app = app
    end

    def app
      super || self.class.app
    end
  end
end
