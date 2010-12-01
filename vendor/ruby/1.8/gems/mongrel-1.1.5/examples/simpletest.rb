$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
require 'mongrel'
require 'yaml'

class SimpleHandler < Mongrel::HttpHandler
  def process(request, response)
    response.start do |head,out|
      head["Content-Type"] = "text/html"
      results = "<html><body>Your request:<br /><pre>#{request.params.to_yaml}</pre><a href=\"/files\">View the files.</a></body></html>"
      out << results
    end
  end
end

class DumbHandler < Mongrel::HttpHandler
  def process(request, response)
    response.start do |head,out|
      head["Content-Type"] = "text/html"
      out.write("test")
    end
  end
end


if ARGV.length != 3
  STDERR.puts "usage:  simpletest.rb <host> <port> <docroot>"
  exit(1)
end

stats = Mongrel::StatisticsFilter.new(:sample_rate => 1)

config = Mongrel::Configurator.new :host => ARGV[0], :port => ARGV[1] do
  listener do
    uri "/", :handler => SimpleHandler.new
    uri "/", :handler => Mongrel::DeflateFilter.new
    uri "/", :handler => stats
    uri "/dumb", :handler => DumbHandler.new
    uri "/dumb", :handler => Mongrel::DeflateFilter.new
    uri "/dumb", :handler => stats
    uri "/files", :handler => Mongrel::DirHandler.new(ARGV[2])
    uri "/files", :handler => stats
    uri "/status", :handler => Mongrel::StatusHandler.new(:stats_filter => stats)
    redirect "/redir1", "/"
    redirect "/to", /to/, 'w'
  end

  trap("INT") { stop }
  run
end

puts "Mongrel running on #{ARGV[0]}:#{ARGV[1]} with docroot #{ARGV[2]}"
config.join
