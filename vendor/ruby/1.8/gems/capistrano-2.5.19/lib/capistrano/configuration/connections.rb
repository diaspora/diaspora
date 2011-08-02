require 'enumerator'
require 'net/ssh/gateway'
require 'capistrano/ssh'
require 'capistrano/errors'

module Capistrano
  class Configuration
    module Connections
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_connections, :initialize
        base.send :alias_method, :initialize, :initialize_with_connections
      end

      class DefaultConnectionFactory #:nodoc:
        def initialize(options)
          @options = options
        end

        def connect_to(server)
          SSH.connect(server, @options)
        end
      end

      class GatewayConnectionFactory #:nodoc:
        def initialize(gateway, options)
          @options = options
          @options[:logger].debug "Creating gateway using #{[*gateway].join(', ')}" if @options[:logger]
          Thread.abort_on_exception = true
          @gateways = [*gateway].collect { |g| ServerDefinition.new(g) }
          tunnel = SSH.connection_strategy(@gateways[0], @options) do |host, user, connect_options|
            Net::SSH::Gateway.new(host, user, connect_options)
          end
          @gateway = (@gateways[1..-1]).inject(tunnel) do |tunnel, destination|
            @options[:logger].debug "Creating tunnel to #{destination}" if @options[:logger]
            local_host = ServerDefinition.new("127.0.0.1", :user => destination.user, :port => tunnel.open(destination.host, (destination.port || 22)))
            SSH.connection_strategy(local_host, @options) do |host, user, connect_options|
              Net::SSH::Gateway.new(host, user, connect_options)
            end
          end
        end
        
        def connect_to(server)
          @options[:logger].debug "establishing connection to `#{server}' via gateway" if @options[:logger]
          local_host = ServerDefinition.new("127.0.0.1", :user => server.user, :port => @gateway.open(server.host, server.port || 22))
          session = SSH.connect(local_host, @options)
          session.xserver = server
          session
        end
      end

      # A hash of the SSH sessions that are currently open and available.
      # Because sessions are constructed lazily, this will only contain
      # connections to those servers that have been the targets of one or more
      # executed tasks. Stored on a per-thread basis to improve thread-safety.
      def sessions
        Thread.current[:sessions] ||= {}
      end

      def initialize_with_connections(*args) #:nodoc:
        initialize_without_connections(*args)
        Thread.current[:sessions] = {}
        Thread.current[:failed_sessions] = []
      end

      # Indicate that the given server could not be connected to.
      def failed!(server)
        Thread.current[:failed_sessions] << server
      end

      # Query whether previous connection attempts to the given server have
      # failed.
      def has_failed?(server)
        Thread.current[:failed_sessions].include?(server)
      end

      # Used to force connections to be made to the current task's servers.
      # Connections are normally made lazily in Capistrano--you can use this
      # to force them open before performing some operation that might be
      # time-sensitive.
      def connect!(options={})
        execute_on_servers(options) { }
      end

      # Returns the object responsible for establishing new SSH connections.
      # The factory will respond to #connect_to, which can be used to
      # establish connections to servers defined via ServerDefinition objects.
      def connection_factory
        @connection_factory ||= begin
          if exists?(:gateway)
            logger.debug "establishing connection to gateway `#{fetch(:gateway)}'"
            GatewayConnectionFactory.new(fetch(:gateway), self)
          else
            DefaultConnectionFactory.new(self)
          end
        end
      end

      # Ensures that there are active sessions for each server in the list.
      def establish_connections_to(servers)
        failed_servers = []

        # force the connection factory to be instantiated synchronously,
        # otherwise we wind up with multiple gateway instances, because
        # each connection is done in parallel.
        connection_factory

        threads = Array(servers).map { |server| establish_connection_to(server, failed_servers) }
        threads.each { |t| t.join }

        if failed_servers.any?
          errors = failed_servers.map { |h| "#{h[:server]} (#{h[:error].class}: #{h[:error].message})" }
          error = ConnectionError.new("connection failed for: #{errors.join(', ')}")
          error.hosts = failed_servers.map { |h| h[:server] }
          raise error
        end
      end

      # Destroys sessions for each server in the list.
      def teardown_connections_to(servers)
        servers.each do |server|
          sessions[server].close
          sessions.delete(server)
        end
      end

      # Determines the set of servers within the current task's scope and
      # establishes connections to them, and then yields that list of
      # servers.
      def execute_on_servers(options={})
        raise ArgumentError, "expected a block" unless block_given?

        if task = current_task
          servers = find_servers_for_task(task, options)

          if servers.empty?
            if ENV['HOSTFILTER']
              logger.info "skipping `#{task.fully_qualified_name}' because no servers matched"
              return
            else
              raise Capistrano::NoMatchingServersError, "`#{task.fully_qualified_name}' is only run for servers matching #{task.options.inspect}, but no servers matched"
            end
          end

          if task.continue_on_error?
            servers.delete_if { |s| has_failed?(s) }
            return if servers.empty?
          end
        else
          servers = find_servers(options)
          raise Capistrano::NoMatchingServersError, "no servers found to match #{options.inspect}" if servers.empty?
        end

        servers = [servers.first] if options[:once]
        logger.trace "servers: #{servers.map { |s| s.host }.inspect}"

        max_hosts = (options[:max_hosts] || (task && task.max_hosts) || servers.size).to_i
        is_subset = max_hosts < servers.size

        # establish connections to those servers in groups of max_hosts, as necessary
        servers.each_slice(max_hosts) do |servers_slice|
          begin
            establish_connections_to(servers_slice)
          rescue ConnectionError => error
            raise error unless task && task.continue_on_error?
            error.hosts.each do |h|
              servers_slice.delete(h)
              failed!(h)
            end
          end

          begin
            yield servers_slice
          rescue RemoteError => error
            raise error unless task && task.continue_on_error?
            error.hosts.each { |h| failed!(h) }
          end

          # if dealing with a subset (e.g., :max_hosts is less than the
          # number of servers available) teardown the subset of connections
          # that were just made, so that we can make room for the next subset.
          teardown_connections_to(servers_slice) if is_subset
        end
      end

      private

        # We establish the connection by creating a thread in a new method--this
        # prevents problems with the thread's scope seeing the wrong 'server'
        # variable if the thread just happens to take too long to start up.
        def establish_connection_to(server, failures=nil)
          current_thread = Thread.current
          Thread.new { safely_establish_connection_to(server, current_thread, failures) }
        end

        def safely_establish_connection_to(server, thread, failures=nil)
          thread[:sessions] ||= {}
          thread[:sessions][server] ||= connection_factory.connect_to(server)
        rescue Exception => err
          raise unless failures
          failures << { :server => server, :error => err }
        end
    end
  end
end
