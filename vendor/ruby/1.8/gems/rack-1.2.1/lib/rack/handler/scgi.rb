require 'scgi'
require 'stringio'
require 'rack/content_length'
require 'rack/chunked'

module Rack
  module Handler
    class SCGI < ::SCGI::Processor
      attr_accessor :app

      def self.run(app, options=nil)
        new(options.merge(:app=>app,
                          :host=>options[:Host],
                          :port=>options[:Port],
                          :socket=>options[:Socket])).listen
      end

      def initialize(settings = {})
        @app = Rack::Chunked.new(Rack::ContentLength.new(settings[:app]))
        super(settings)
      end

      def process_request(request, input_body, socket)
        env = {}.replace(request)
        env.delete "HTTP_CONTENT_TYPE"
        env.delete "HTTP_CONTENT_LENGTH"
        env["REQUEST_PATH"], env["QUERY_STRING"] = env["REQUEST_URI"].split('?', 2)
        env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
        env["PATH_INFO"] = env["REQUEST_PATH"]
        env["QUERY_STRING"] ||= ""
        env["SCRIPT_NAME"] = ""

        rack_input = StringIO.new(input_body)
        rack_input.set_encoding(Encoding::BINARY) if rack_input.respond_to?(:set_encoding)

        env.update({"rack.version" => Rack::VERSION,
                     "rack.input" => rack_input,
                     "rack.errors" => $stderr,
                     "rack.multithread" => true,
                     "rack.multiprocess" => true,
                     "rack.run_once" => false,

                     "rack.url_scheme" => ["yes", "on", "1"].include?(env["HTTPS"]) ? "https" : "http"
                   })
        status, headers, body = app.call(env)
        begin
          socket.write("Status: #{status}\r\n")
          headers.each do |k, vs|
            vs.split("\n").each { |v| socket.write("#{k}: #{v}\r\n")}
          end
          socket.write("\r\n")
          body.each {|s| socket.write(s)}
        ensure
          body.close if body.respond_to? :close
        end
      end
    end
  end
end
