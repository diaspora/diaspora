module Thin
  # The uterly famous Thin HTTP server.
  # It listen for incoming request through a given +backend+
  # and forward all request to +app+.
  #
  # == TCP server
  # Create a new TCP server on bound to <tt>host:port</tt> by specifiying +host+
  # and +port+ as the first 2 arguments.
  #
  #   Thin::Server.start('0.0.0.0', 3000, app)
  #
  # == UNIX domain server
  # Create a new UNIX domain socket bound to +socket+ file by specifiying a filename
  # as the first argument. Eg.: /tmp/thin.sock. If the first argument contains a <tt>/</tt>
  # it will be assumed to be a UNIX socket. 
  #
  #   Thin::Server.start('/tmp/thin.sock', app)
  #
  # == Using a custom backend
  # You can implement your own way to connect the server to its client by creating your
  # own Backend class and pass it as the :backend option.
  #
  #   Thin::Server.start('galaxy://faraway', 1345, app, :backend => Thin::Backends::MyFancyBackend)
  #
  # == Rack application (+app+)
  # All requests will be processed through +app+ that must be a valid Rack adapter.
  # A valid Rack adapter (application) must respond to <tt>call(env#Hash)</tt> and
  # return an array of <tt>[status, headers, body]</tt>.
  #
  # == Building an app in place
  # If a block is passed, a <tt>Rack::Builder</tt> instance
  # will be passed to build the +app+. So you can do cool stuff like this:
  # 
  #   Thin::Server.start('0.0.0.0', 3000) do
  #     use Rack::CommonLogger
  #     use Rack::ShowExceptions
  #     map "/lobster" do
  #       use Rack::Lint
  #       run Rack::Lobster.new
  #     end
  #   end
  #
  # == Controlling with signals
  # * QUIT: Gracefull shutdown (see Server#stop)
  # * INT and TERM: Force shutdown (see Server#stop!)
  # Disable signals by passing <tt>:signals => false</tt>
  # 
  class Server
    include Logging
    include Daemonizable
    extend  Forwardable
    
    # Default values
    DEFAULT_TIMEOUT                        = 30 #sec
    DEFAULT_HOST                           = '0.0.0.0'
    DEFAULT_PORT                           = 3000
    DEFAULT_MAXIMUM_CONNECTIONS            = 1024
    DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS = 512
        
    # Application (Rack adapter) called with the request that produces the response.
    attr_accessor :app

    # A tag that will show in the process listing
    attr_accessor :tag

    # Backend handling the connections to the clients.
    attr_accessor :backend
    
    # Maximum number of seconds for incoming data to arrive before the connection
    # is dropped.
    def_delegators :backend, :timeout, :timeout=
    
    # Maximum number of file or socket descriptors that the server may open.
    def_delegators :backend, :maximum_connections, :maximum_connections=
    
    # Maximum number of connection that can be persistent at the same time.
    # Most browser never close the connection so most of the time they are closed
    # when the timeout occur. If we don't control the number of persistent connection,
    # if would be very easy to overflow the server for a DoS attack.
    def_delegators :backend, :maximum_persistent_connections, :maximum_persistent_connections=
    
    # Allow using threads in the backend.
    def_delegators :backend, :threaded?, :threaded=
    
    # Address and port on which the server is listening for connections.
    def_delegators :backend, :host, :port
    
    # UNIX domain socket on which the server is listening for connections.
    def_delegator :backend, :socket
    
    # Disable the use of epoll under Linux
    def_delegators :backend, :no_epoll, :no_epoll=
    
    def initialize(*args, &block)
      host, port, options = DEFAULT_HOST, DEFAULT_PORT, {}
      
      # Guess each parameter by its type so they can be
      # received in any order.
      args.each do |arg|
        case arg
        when Fixnum, /^\d+$/ then port    = arg.to_i
        when String          then host    = arg
        when Hash            then options = arg
        else
          @app = arg if arg.respond_to?(:call)
        end
      end
      
      # Set tag if needed
      self.tag = options[:tag]

      # Try to intelligently select which backend to use.
      @backend = select_backend(host, port, options)
      
      load_cgi_multipart_eof_fix
      
      @backend.server = self
      
      # Set defaults
      @backend.maximum_connections            = DEFAULT_MAXIMUM_CONNECTIONS
      @backend.maximum_persistent_connections = DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS
      @backend.timeout                        = DEFAULT_TIMEOUT
      
      # Allow using Rack builder as a block
      @app = Rack::Builder.new(&block).to_app if block
      
      # If in debug mode, wrap in logger adapter
      @app = Rack::CommonLogger.new(@app) if Logging.debug?
      
      setup_signals unless options[:signals].class == FalseClass
    end
    
    # Lil' shortcut to turn this:
    # 
    #   Server.new(...).start
    # 
    # into this:
    # 
    #   Server.start(...)
    # 
    def self.start(*args, &block)
      new(*args, &block).start!
    end
        
    # Start the server and listen for connections.
    def start
      raise ArgumentError, 'app required' unless @app
      
      log   ">> Thin web server (v#{VERSION::STRING} codename #{VERSION::CODENAME})"
      debug ">> Debugging ON"
      trace ">> Tracing ON"
      
      log ">> Maximum connections set to #{@backend.maximum_connections}"
      log ">> Listening on #{@backend}, CTRL+C to stop"
      
      @backend.start
    end
    alias :start! :start
    
    # == Gracefull shutdown
    # Stops the server after processing all current connections.
    # As soon as this method is called, the server stops accepting
    # new requests and wait for all current connections to finish.
    # Calling twice is the equivalent of calling <tt>stop!</tt>.
    def stop
      if running?
        @backend.stop
        unless @backend.empty?
          log ">> Waiting for #{@backend.size} connection(s) to finish, " +
                 "can take up to #{timeout} sec, CTRL+C to stop now"
        end
      else
        stop!
      end
    end
    
    # == Force shutdown
    # Stops the server closing all current connections right away.
    # This doesn't wait for connection to finish their work and send data.
    # All current requests will be dropped.
    def stop!
      log ">> Stopping ..."

      @backend.stop!
    end
    
    # == Configure the server
    # The process might need to have superuser privilege to configure
    # server with optimal options.
    def config
      @backend.config
    end
    
    # Name of the server and type of backend used.
    # This is also the name of the process in which Thin is running as a daemon.
    def name
      "thin server (#{@backend})" + (tag ? " [#{tag}]" : "")
    end
    alias :to_s :name
    
    # Return +true+ if the server is running and ready to receive requests.
    # Note that the server might still be running and return +false+ when
    # shuting down and waiting for active connections to complete.
    def running?
      @backend.running?
    end
    
    protected
      # Register signals:
      # * INT calls +stop+ to shutdown gracefully.
      # * TERM calls <tt>stop!</tt> to force shutdown.
      def setup_signals
        trap('INT')  { stop! }
        trap('TERM') { stop! }
        unless Thin.win?
          trap('QUIT') { stop }
          trap('HUP')  { restart }
        end
      end
      
      def select_backend(host, port, options)
        case
        when options.has_key?(:backend)
          raise ArgumentError, ":backend must be a class" unless options[:backend].is_a?(Class)
          options[:backend].new(host, port, options)
        when options.has_key?(:swiftiply)
          Backends::SwiftiplyClient.new(host, port, options)
        when host.include?('/')
          Backends::UnixServer.new(host)
        else
          Backends::TcpServer.new(host, port)
        end
      end
      
      # Taken from Mongrel cgi_multipart_eof_fix
      # Ruby 1.8.5 has a security bug in cgi.rb, we need to patch it.
      def load_cgi_multipart_eof_fix
        version = RUBY_VERSION.split('.').map { |i| i.to_i }
        
        if version[0] <= 1 && version[1] <= 8 && version[2] <= 5 && RUBY_PLATFORM !~ /java/
          begin
            require 'cgi_multipart_eof_fix'
          rescue LoadError
            log "!! Ruby 1.8.5 is not secure please install cgi_multipart_eof_fix:"
            log "   gem install cgi_multipart_eof_fix"
          end
        end
      end
  end
end