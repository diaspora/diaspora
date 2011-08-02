require 'webrick'

module YARD
  module Server
    # The main adapter to initialize a WEBrick server.
    class WebrickAdapter < Adapter
      # Initializes a WEBrick server. If {Adapter#server_options} contains a
      # +:daemonize+ key set to true, the server will be daemonized.
      def start
        server_options[:ServerType] = WEBrick::Daemon if server_options[:daemonize]
        server = WEBrick::HTTPServer.new(server_options)
        server.mount('/', WebrickServlet, self)
        trap("INT") { server.shutdown }
        server.start
      end
    end

    # The main WEBrick servlet implementation, accepting only GET requests.
    class WebrickServlet < WEBrick::HTTPServlet::AbstractServlet
      attr_accessor :adapter

      def initialize(server, adapter)
        super
        self.adapter = adapter
      end

      def do_GET(request, response)
        status, headers, body = *adapter.router.call(request)
        response.status = status
        response.body = body.is_a?(Array) ? body[0] : body
        headers.each do |key, value|
          response[key] = value
        end
      end
    end
  end
end

# @private
class WEBrick::HTTPRequest
  def xhr?; (self['X-Requested-With'] || "").downcase == 'xmlhttprequest' end
end
