
# Standard libraries
require 'socket'
require 'tempfile'
require 'yaml'
require 'time'
require 'etc'
require 'uri'
require 'stringio'

# Compiled Mongrel extension
require 'http11'

# Gem conditional loader
require 'mongrel/gems'
Mongrel::Gems.require 'cgi_multipart_eof_fix'
Mongrel::Gems.require 'fastthread'
require 'thread'

# Ruby Mongrel
require 'mongrel/cgi'
require 'mongrel/handlers'
require 'mongrel/command'
require 'mongrel/tcphack'
require 'mongrel/configurator'
require 'mongrel/uri_classifier'
require 'mongrel/const'
require 'mongrel/http_request'
require 'mongrel/header_out'
require 'mongrel/http_response'

# Mongrel module containing all of the classes (include C extensions) for running
# a Mongrel web server.  It contains a minimalist HTTP server with just enough
# functionality to service web application requests fast as possible.
module Mongrel

  # Used to stop the HttpServer via Thread.raise.
  class StopServer < Exception; end

  # Thrown at a thread when it is timed out.
  class TimeoutError < Exception; end

  # A Hash with one extra parameter for the HTTP body, used internally.
  class HttpParams < Hash
    attr_accessor :http_body
  end


  # This is the main driver of Mongrel, while the Mongrel::HttpParser and Mongrel::URIClassifier
  # make up the majority of how the server functions.  It's a very simple class that just
  # has a thread accepting connections and a simple HttpServer.process_client function
  # to do the heavy lifting with the IO and Ruby.  
  #
  # You use it by doing the following:
  #
  #   server = HttpServer.new("0.0.0.0", 3000)
  #   server.register("/stuff", MyNiftyHandler.new)
  #   server.run.join
  #
  # The last line can be just server.run if you don't want to join the thread used.
  # If you don't though Ruby will mysteriously just exit on you.
  #
  # Ruby's thread implementation is "interesting" to say the least.  Experiments with
  # *many* different types of IO processing simply cannot make a dent in it.  Future
  # releases of Mongrel will find other creative ways to make threads faster, but don't
  # hold your breath until Ruby 1.9 is actually finally useful.
  class HttpServer
    attr_reader :acceptor
    attr_reader :workers
    attr_reader :classifier
    attr_reader :host
    attr_reader :port
    attr_reader :throttle
    attr_reader :timeout
    attr_reader :num_processors

    # Creates a working server on host:port (strange things happen if port isn't a Number).
    # Use HttpServer::run to start the server and HttpServer.acceptor.join to 
    # join the thread that's processing incoming requests on the socket.
    #
    # The num_processors optional argument is the maximum number of concurrent
    # processors to accept, anything over this is closed immediately to maintain
    # server processing performance.  This may seem mean but it is the most efficient
    # way to deal with overload.  Other schemes involve still parsing the client's request
    # which defeats the point of an overload handling system.
    # 
    # The throttle parameter is a sleep timeout (in hundredths of a second) that is placed between 
    # socket.accept calls in order to give the server a cheap throttle time.  It defaults to 0 and
    # actually if it is 0 then the sleep is not done at all.
    def initialize(host, port, num_processors=950, throttle=0, timeout=60)
      
      tries = 0
      @socket = TCPServer.new(host, port) 
      
      @classifier = URIClassifier.new
      @host = host
      @port = port
      @workers = ThreadGroup.new
      @throttle = throttle / 100.0
      @num_processors = num_processors
      @timeout = timeout
    end

    # Does the majority of the IO processing.  It has been written in Ruby using
    # about 7 different IO processing strategies and no matter how it's done 
    # the performance just does not improve.  It is currently carefully constructed
    # to make sure that it gets the best possible performance, but anyone who
    # thinks they can make it faster is more than welcome to take a crack at it.
    def process_client(client)
      begin
        parser = HttpParser.new
        params = HttpParams.new
        request = nil
        data = client.readpartial(Const::CHUNK_SIZE)
        nparsed = 0

        # Assumption: nparsed will always be less since data will get filled with more
        # after each parsing.  If it doesn't get more then there was a problem
        # with the read operation on the client socket.  Effect is to stop processing when the
        # socket can't fill the buffer for further parsing.
        while nparsed < data.length
          nparsed = parser.execute(params, data, nparsed)

          if parser.finished?
            if not params[Const::REQUEST_PATH]
              # it might be a dumbass full host request header
              uri = URI.parse(params[Const::REQUEST_URI])
              params[Const::REQUEST_PATH] = uri.path
            end

            raise "No REQUEST PATH" if not params[Const::REQUEST_PATH]

            script_name, path_info, handlers = @classifier.resolve(params[Const::REQUEST_PATH])

            if handlers
              params[Const::PATH_INFO] = path_info
              params[Const::SCRIPT_NAME] = script_name

              # From http://www.ietf.org/rfc/rfc3875 :
              # "Script authors should be aware that the REMOTE_ADDR and REMOTE_HOST
              #  meta-variables (see sections 4.1.8 and 4.1.9) may not identify the
              #  ultimate source of the request.  They identify the client for the
              #  immediate request to the server; that client may be a proxy, gateway,
              #  or other intermediary acting on behalf of the actual source client."
              params[Const::REMOTE_ADDR] = client.peeraddr.last

              # select handlers that want more detailed request notification
              notifiers = handlers.select { |h| h.request_notify }
              request = HttpRequest.new(params, client, notifiers)

              # in the case of large file uploads the user could close the socket, so skip those requests
              break if request.body == nil  # nil signals from HttpRequest::initialize that the request was aborted

              # request is good so far, continue processing the response
              response = HttpResponse.new(client)

              # Process each handler in registered order until we run out or one finalizes the response.
              handlers.each do |handler|
                handler.process(request, response)
                break if response.done or client.closed?
              end

              # And finally, if nobody closed the response off, we finalize it.
              unless response.done or client.closed? 
                response.finished
              end
            else
              # Didn't find it, return a stock 404 response.
              client.write(Const::ERROR_404_RESPONSE)
            end

            break #done
          else
            # Parser is not done, queue up more data to read and continue parsing
            chunk = client.readpartial(Const::CHUNK_SIZE)
            break if !chunk or chunk.length == 0  # read failed, stop processing

            data << chunk
            if data.length >= Const::MAX_HEADER
              raise HttpParserError.new("HEADER is longer than allowed, aborting client early.")
            end
          end
        end
      rescue EOFError,Errno::ECONNRESET,Errno::EPIPE,Errno::EINVAL,Errno::EBADF
        client.close rescue nil
      rescue HttpParserError => e
        STDERR.puts "#{Time.now}: HTTP parse error, malformed request (#{params[Const::HTTP_X_FORWARDED_FOR] || client.peeraddr.last}): #{e.inspect}"
        STDERR.puts "#{Time.now}: REQUEST DATA: #{data.inspect}\n---\nPARAMS: #{params.inspect}\n---\n"
      rescue Errno::EMFILE
        reap_dead_workers('too many files')
      rescue Object => e
        STDERR.puts "#{Time.now}: Read error: #{e.inspect}"
        STDERR.puts e.backtrace.join("\n")
      ensure
        begin
          client.close
        rescue IOError
          # Already closed
        rescue Object => e
          STDERR.puts "#{Time.now}: Client error: #{e.inspect}"
          STDERR.puts e.backtrace.join("\n")
        end
        request.body.delete if request and request.body.class == Tempfile
      end
    end

    # Used internally to kill off any worker threads that have taken too long
    # to complete processing.  Only called if there are too many processors
    # currently servicing.  It returns the count of workers still active
    # after the reap is done.  It only runs if there are workers to reap.
    def reap_dead_workers(reason='unknown')
      if @workers.list.length > 0
        STDERR.puts "#{Time.now}: Reaping #{@workers.list.length} threads for slow workers because of '#{reason}'"
        error_msg = "Mongrel timed out this thread: #{reason}"
        mark = Time.now
        @workers.list.each do |worker|
          worker[:started_on] = Time.now if not worker[:started_on]

          if mark - worker[:started_on] > @timeout + @throttle
            STDERR.puts "Thread #{worker.inspect} is too old, killing."
            worker.raise(TimeoutError.new(error_msg))
          end
        end
      end

      return @workers.list.length
    end

    # Performs a wait on all the currently running threads and kills any that take
    # too long.  It waits by @timeout seconds, which can be set in .initialize or
    # via mongrel_rails. The @throttle setting does extend this waiting period by
    # that much longer.
    def graceful_shutdown
      while reap_dead_workers("shutdown") > 0
        STDERR.puts "Waiting for #{@workers.list.length} requests to finish, could take #{@timeout + @throttle} seconds."
        sleep @timeout / 10
      end
    end

    def configure_socket_options
      case RUBY_PLATFORM
      when /linux/
        # 9 is currently TCP_DEFER_ACCEPT
        $tcp_defer_accept_opts = [Socket::SOL_TCP, 9, 1]
        $tcp_cork_opts = [Socket::SOL_TCP, 3, 1]
      when /freebsd(([1-4]\..{1,2})|5\.[0-4])/
        # Do nothing, just closing a bug when freebsd <= 5.4
      when /freebsd/
        # Use the HTTP accept filter if available.
        # The struct made by pack() is defined in /usr/include/sys/socket.h as accept_filter_arg
        unless `/sbin/sysctl -nq net.inet.accf.http`.empty?
          $tcp_defer_accept_opts = [Socket::SOL_SOCKET, Socket::SO_ACCEPTFILTER, ['httpready', nil].pack('a16a240')]
        end
      end
    end
    
    # Runs the thing.  It returns the thread used so you can "join" it.  You can also
    # access the HttpServer::acceptor attribute to get the thread later.
    def run
      BasicSocket.do_not_reverse_lookup=true

      configure_socket_options

      if defined?($tcp_defer_accept_opts) and $tcp_defer_accept_opts
        @socket.setsockopt(*$tcp_defer_accept_opts) rescue nil
      end

      @acceptor = Thread.new do
        begin
          while true
            begin
              client = @socket.accept
  
              if defined?($tcp_cork_opts) and $tcp_cork_opts
                client.setsockopt(*$tcp_cork_opts) rescue nil
              end
  
              worker_list = @workers.list
  
              if worker_list.length >= @num_processors
                STDERR.puts "Server overloaded with #{worker_list.length} processors (#@num_processors max). Dropping connection."
                client.close rescue nil
                reap_dead_workers("max processors")
              else
                thread = Thread.new(client) {|c| process_client(c) }
                thread[:started_on] = Time.now
                @workers.add(thread)
  
                sleep @throttle if @throttle > 0
              end
            rescue StopServer
              break
            rescue Errno::EMFILE
              reap_dead_workers("too many open files")
              sleep 0.5
            rescue Errno::ECONNABORTED
              # client closed the socket even before accept
              client.close rescue nil
            rescue Object => e
              STDERR.puts "#{Time.now}: Unhandled listen loop exception #{e.inspect}."
              STDERR.puts e.backtrace.join("\n")
            end
          end
          graceful_shutdown
        ensure
          @socket.close
          # STDERR.puts "#{Time.now}: Closed socket."
        end
      end

      return @acceptor
    end

    # Simply registers a handler with the internal URIClassifier.  When the URI is
    # found in the prefix of a request then your handler's HttpHandler::process method
    # is called.  See Mongrel::URIClassifier#register for more information.
    #
    # If you set in_front=true then the passed in handler will be put in the front of the list
    # for that particular URI. Otherwise it's placed at the end of the list.
    def register(uri, handler, in_front=false)
      begin
        @classifier.register(uri, [handler])
      rescue URIClassifier::RegistrationError
        handlers = @classifier.resolve(uri)[2]
        method_name = in_front ? 'unshift' : 'push'
        handlers.send(method_name, handler)
      end
      handler.listener = self
    end

    # Removes any handlers registered at the given URI.  See Mongrel::URIClassifier#unregister
    # for more information.  Remember this removes them *all* so the entire
    # processing chain goes away.
    def unregister(uri)
      @classifier.unregister(uri)
    end

    # Stops the acceptor thread and then causes the worker threads to finish
    # off the request queue before finally exiting.
    def stop(synchronous=false)
      @acceptor.raise(StopServer.new)

      if synchronous
        sleep(0.5) while @acceptor.alive?
      end
    end

  end
end

# Load experimental library, if present. We put it here so it can override anything
# in regular Mongrel.

$LOAD_PATH.unshift 'projects/mongrel_experimental/lib/'
Mongrel::Gems.require 'mongrel_experimental', ">=#{Mongrel::Const::MONGREL_VERSION}"
