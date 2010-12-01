# This script emualtes script/server behavior but running webrick http server 
require 'rubygems'

require 'mongrel'
require 'yaml'
require 'zlib'

require 'win32/service'

DEBUG_LOG_FILE = File.expand_path(File.dirname(__FILE__) + '/debug.log') 

class SimpleHandler < Mongrel::HttpHandler
    def process(request, response)
      response.start do |head,out|
        head["Content-Type"] = "text/html"
        results = "<html><body>Your request:<br /><pre>#{request.params.to_yaml}</pre><a href=\"/files\">View the files.</a></body></html>"
        if request.params["HTTP_ACCEPT_ENCODING"] == "gzip,deflate"
          head["Content-Encoding"] = "deflate"
          # send it back deflated
          out << Zlib::Deflate.deflate(results)
        else
          # no gzip supported, send it back normal
          out << results
        end
      end
    end
end

class MongrelDaemon < Win32::Daemon
  def initialize(options)
    @options = options
  end
  
  def service_init
    File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("#{Time.now} - service_init entered") }

    File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("Mongrel running on #{@options[:ip]}:#{@options[:port]} with docroot #{@options[:server_root]}") } 

    @simple = SimpleHandler.new
    @files = Mongrel::DirHandler.new(@options[:server_root])

    @http_server = Mongrel::HttpServer.new(@options[:ip], @options[:port])
    @http_server.register("/", @simple)
    @http_server.register("/files", @files)

    File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("#{Time.now} - service_init left") }
  end
  
  def service_stop
    File.open(DEBUG_LOG_FILE,"a+"){ |f|
      f.puts "stop signal received: " + Time.now.to_s
      f.puts "sending stop to mongrel threads: " + Time.now.to_s
    }
    #@http_server.stop
  end

  def service_pause
    File.open(DEBUG_LOG_FILE,"a+"){ |f|
      f.puts "pause signal received: " + Time.now.to_s
    }
  end
  
  def service_resume
    File.open(DEBUG_LOG_FILE,"a+"){ |f|
      f.puts "continue/resume signal received: " + Time.now.to_s
    }
  end

  def service_main
    File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("#{Time.now} - service_main entered") }
    
    begin
      File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("#{Time.now} - http_server.run") }
      @http_server.run
    
      # No runner thread was needed after all!
      #@runner = Thread.new do
      #  @http_server.acceptor.join
      #end
      #File.open("d:\\test.log","a+") { |f| f.puts("#{Time.now} - runner.run") }
      #@runner.run
      
      # here is where magic happens!
      # if put blocking code here, the thread never left service_main, and the rb_func_call in service.c
      # never exit, even if the stop signal is received.
      #
      # to probe my theory, just comment the while loop and remove the '1' from sleep function
      # service start ok, but fail to stop.
      #
      # Even if no functional code is in service_main (because we have other working threads),
      # we must monitor the state of the service to exit when the STOP event is received.
      #
      # Note: maybe not loop in 1 second intervals?
      while state == RUNNING
        sleep 1
      end
      
    rescue StandardError, Exception, interrupt  => err
      File.open(DEBUG_LOG_FILE,"a+"){ |f| f.puts("#{Time.now} - Error: #{err}") }
      File.open(DEBUG_LOG_FILE,"a+"){ |f| f.puts("BACKTRACE: " + err.backtrace.join("\n")) }
      
    end
    
    File.open(DEBUG_LOG_FILE,"a+") { |f| f.puts("#{Time.now} - service_main left") }
  end
  
end

OPTIONS = {
  :port            => 3000,
  :ip              => "0.0.0.0",
  :server_root     => File.expand_path(File.dirname(__FILE__)),
}

web_server = MongrelDaemon.new(OPTIONS)
web_server.mainloop
