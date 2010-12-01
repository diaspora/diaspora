require 'mongrel'
require 'active_support'
require 'lib/httparty'
require 'spec/expectations'

Before do
  def new_port
    server = TCPServer.new('0.0.0.0', nil)
    port = server.addr[1]
  ensure
    server.close
  end

  port = ENV["HTTPARTY_PORT"] || new_port
  @host_and_port = "0.0.0.0:#{port}"
  @server = Mongrel::HttpServer.new("0.0.0.0", port)
  @server.run
  @request_options = {}
end

After do
  @server.stop
end
