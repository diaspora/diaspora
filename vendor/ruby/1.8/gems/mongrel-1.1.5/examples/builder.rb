require 'mongrel'

class TestPlugin < GemPlugin::Plugin "/handlers"
  include Mongrel::HttpHandlerPlugin

  def process(request, response)
    STDERR.puts "My options are: #{options.inspect}"
    STDERR.puts "Request Was:"
    STDERR.puts request.params.to_yaml
  end
end

config = Mongrel::Configurator.new :host => "127.0.0.1" do
  load_plugins :includes => ["mongrel"], :excludes => ["rails"]
  daemonize :cwd => Dir.pwd, :log_file => "mongrel.log", :pid_file => "mongrel.pid"
  
  listener :port => 3000 do
    uri "/app", :handler => plugin("/handlers/testplugin", :test => "that")
    uri "/app", :handler => Mongrel::DirHandler.new(".")
    load_plugins :includes => ["mongrel", "rails"]
  end

  trap("INT") { stop }
  run
end

config.join


