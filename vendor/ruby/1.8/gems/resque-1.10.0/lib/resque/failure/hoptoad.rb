require 'net/https'
require 'builder'
require 'uri'

module Resque
  module Failure
    # A Failure backend that sends exceptions raised by jobs to Hoptoad.
    #
    # To use it, put this code in an initializer, Rake task, or wherever:
    #
    #   require 'resque/failure/hoptoad'
    #
    #   Resque::Failure::Hoptoad.configure do |config|
    #     config.api_key = 'blah'
    #     config.secure = true
    #
    #     # optional proxy support
    #     config.proxy_host = 'x.y.z.t'
    #     config.proxy_port = 8080
    #
    #     # server env support, defaults to RAILS_ENV or RACK_ENV
    #     config.server_environment = "test"
    #   end
    class Hoptoad < Base
      # From the hoptoad plugin
      INPUT_FORMAT = /^([^:]+):(\d+)(?::in `([^']+)')?$/

      class << self
        attr_accessor :secure, :api_key, :proxy_host, :proxy_port
        attr_accessor :server_environment
      end

      def self.count
        # We can't get the total # of errors from Hoptoad so we fake it
        # by asking Resque how many errors it has seen.
        Stat[:failed]
      end

      def self.configure
        yield self
        Resque::Failure.backend = self
      end

      def save
        http = use_ssl? ? :https : :http
        url = URI.parse("#{http}://hoptoadapp.com/notifier_api/v2/notices")

        request = Net::HTTP::Proxy(self.class.proxy_host, self.class.proxy_port)
        http = request.new(url.host, url.port)
        headers = {
          'Content-type' => 'text/xml',
          'Accept' => 'text/xml, application/xml'
        }

        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds

        http.use_ssl = use_ssl?

        begin
          response = http.post(url.path, xml, headers)
        rescue TimeoutError => e
          log "Timeout while contacting the Hoptoad server."
        end

        case response
        when Net::HTTPSuccess then
          log "Hoptoad Success: #{response.class}"
        else
          body = response.body if response.respond_to? :body
          log "Hoptoad Failure: #{response.class}\n#{body}"
        end
      end

      def xml
        x = Builder::XmlMarkup.new
        x.instruct!
        x.notice :version=>"2.0" do
          x.tag! "api-key", api_key
          x.notifier do
            x.name "Resqueue"
            x.version "0.1"
            x.url "http://github.com/defunkt/resque"
          end
          x.error do
            x.tag! "class", exception.class.name
            x.message "#{exception.class.name}: #{exception.message}"
            x.backtrace do
              fill_in_backtrace_lines(x)
            end
          end
          x.request do
            x.url queue.to_s
            x.component worker.to_s
            x.params do
              x.var :key=>"payload_class" do
                x.text! payload["class"].to_s
              end
              x.var :key=>"payload_args" do
                x.text! payload["args"].to_s
              end
            end
          end
          x.tag!("server-environment") do
            x.tag!("environment-name",server_environment)
          end

        end
      end

      def fill_in_backtrace_lines(x)
        Array(exception.backtrace).each do |unparsed_line|
          _, file, number, method = unparsed_line.match(INPUT_FORMAT).to_a
          x.line :file => file,:number => number
        end
      end

      def use_ssl?
        self.class.secure
      end

      def api_key
        self.class.api_key
      end

      def server_environment
        return self.class.server_environment if self.class.server_environment
        defined?(RAILS_ENV) ? RAILS_ENV : (ENV['RACK_ENV'] || 'development')
      end
    end
  end
end
