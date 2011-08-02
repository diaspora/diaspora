module Selenium
  module WebDriver
    module Chrome

      #
      # @api private
      #

      class Service
        START_TIMEOUT = 20
        STOP_TIMEOUT  = 5
        MISSING_TEXT  = "Unable to find the chromedriver executable. Please download the server from http://code.google.com/p/selenium/downloads/list and place it somewhere on your PATH. More info at http://code.google.com/p/selenium/wiki/ChromeDriver."

        attr_reader :uri

        def self.executable_path
          @executable_path ||= (
            Platform.find_binary "chromedriver" or raise Error::WebDriverError, MISSING_TEXT
          )
        end

        def self.executable_path=(path)
          Platform.assert_executable path
          @executable_path = path
        end

        def self.default_service
          new executable_path, PortProber.random
        end

        def initialize(executable_path, port)
          @uri           = URI.parse "http://#{Platform.localhost}:#{port}"
          server_command = [executable_path, "--port=#{port}"]

          @process       = ChildProcess.build(*server_command)
          @socket_poller = SocketPoller.new Platform.localhost, port, START_TIMEOUT

          @process.io.inherit! if $DEBUG == true
        end

        def start
          @process.start

          unless @socket_poller.connected?
            raise Error::WebDriverError, "unable to connect to chromedriver #{@uri}"
          end

          at_exit { stop } # make sure we don't leave the server running
        end

        def stop
          return if @process.nil? || @process.exited?

          Net::HTTP.get uri.host, '/shutdown', uri.port
          @process.poll_for_exit STOP_TIMEOUT
        rescue ChildProcess::TimeoutError
          # ok, force quit
          @process.stop STOP_TIMEOUT
        end
      end # Service

    end # Chrome
  end # WebDriver
end # Service