require 'thread'
require 'net/ssh'
require 'net/ssh/version'

# A Gateway is an object that allows you to tunnel network connections through
# a publicly visible host to a host hidden behind it. This is particularly
# useful when dealing with hosts behind a firewall. One host will generally
# be visible (and accessible) outside the firewall, while the others will all
# be behind the firewall, and the only way to access those restricted hosts
# is by first logging into the publicly visible host, and from thence logging
# into the restricted ones.
#
# This class makes it easy to programmatically connect to these restricted
# hosts via SSH. You can either simply forward a port from the local host to
# the remote host, or you can open a new Net::SSH connection to the remote
# host via a forwarded port.
#
#   require 'net/ssh/gateway'
#
#   gateway = Net::SSH::Gateway.new('host.name', 'user')
#
#   gateway.open('hidden.host', 80) do |port|
#     Net::HTTP.get_print '127.0.0.1', '/path', port
#   end
#
#   gateway.ssh('hidden.host', 'user') do |ssh|
#     puts ssh.exec!("hostname")
#   end
#
#   gateway.shutdown!
#
# Port numbers are allocated automatically, beginning at MAX_PORT and
# decrementing on each request for a new port until MIN_PORT is reached. If
# a port is already in use, this is detected and a different port will be
# assigned. 
class Net::SSH::Gateway
  # A trivial class for representing the version of this library.
  class Version < Net::SSH::Version
    # The major component of the library's version
    MAJOR = 1

    # The minor component of the library's version
    MINOR = 1

    # The tiny component of the library's version
    TINY  = 0

    # The library's version as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The library's version as a String instance
    STRING = CURRENT.to_s
  end

  # The maximum port number that the gateway will attempt to use to forward
  # connections from.
  MAX_PORT = 65535

  # The minimum port number that the gateway will attempt to use to forward
  # connections from.
  MIN_PORT = 1024

  # Instantiate a new Gateway object, using the given remote host as the
  # tunnel. The arguments here are identical to those for Net::SSH.start, and
  # are passed as given to that method to start up the gateway connection.
  #
  #   gateway = Net::SSH::Gateway.new('host', 'user', :password => "password")
  # 
  # As of 1.1 there is an additional option to specify the wait time for 
  # the gateway thread. The default is 0.001 seconds and can be changed
  # with the :loop_wait option.
  #
  def initialize(host, user, options={})
    @session = Net::SSH.start(host, user, options)
    @session_mutex = Mutex.new
    @port_mutex = Mutex.new
    @next_port = MAX_PORT
    @loop_wait = options.delete(:loop_wait) || 0.001
    initiate_event_loop!
  end

  # Returns +true+ if the gateway is currently open and accepting connections.
  # This will be the case unless #shutdown! has been invoked.
  def active?
    @active
  end

  # Shuts down the gateway by closing all forwarded ports and then closing
  # the gateway's SSH session.
  def shutdown!
    return unless active?

    @session_mutex.synchronize do
      # cancel all active forward channels
      @session.forward.active_locals.each do |lport, host, port|
        @session.forward.cancel_local(lport)
      end
    end

    @active = false
    
    @thread.join
    @session.close
  end

  # Opens a new port on the local host and forwards it to the given host/port
  # via the gateway host. If a block is given, the newly allocated port
  # number will be yielded to the block, and the port automatically closed
  # (see #close) when the block finishes. Otherwise, the port number will be
  # returned, and the caller is responsible for closing the port (#close).
  #
  #   gateway.open('host', 80) do |port|
  #     # ...
  #   end
  #
  #   port = gateway.open('host', 80)
  #   # ...
  #   gateway.close(port)
  #
  # If +local_port+ is not specified, the next available port will be used.
  def open(host, port, local_port=nil)
    ensure_open!

    actual_local_port = local_port || next_port

    @session_mutex.synchronize do
      @session.forward.local(actual_local_port, host, port)
    end

    if block_given?
      begin
        yield actual_local_port
      ensure
        close(actual_local_port)
      end
    else
      return actual_local_port
    end
  rescue Errno::EADDRINUSE
    raise if local_port # if a local port was explicitly requested, bubble the error up
    retry
  end

  # Cancels port-forwarding over an open port that was previously opened via
  # #open.
  def close(port)
    ensure_open!

    @session_mutex.synchronize do
      @session.forward.cancel_local(port)
    end
  end

  # Forwards a new connection to the given +host+ and opens a new Net::SSH
  # connection to that host over the forwarded port. If a block is given,
  # the new SSH connection will be yielded to the block, and autoclosed
  # when the block terminates. The forwarded port will be autoclosed as well.
  # If no block was given, the new SSH connection will be returned, and it
  # is up to the caller to terminate both the connection and the forwarded
  # port when done.
  #
  #   gateway.ssh('host', 'user') do |ssh|
  #     # ...
  #   end
  #
  #   ssh = gateway.ssh('host', 'user')
  #   # ...
  #   ssh.close
  #   gateway.close(ssh.transport.port)
  def ssh(host, user, options={}, &block)
    local_port = open(host, options[:port] || 22)

    begin
      Net::SSH.start("127.0.0.1", user, options.merge(:port => local_port), &block)
    ensure
      close(local_port) if block || $!
    end
  end

  private

    # Raises a RuntimeError if the gateway is not active. This is used as a
    # sanity check to make sure a client doesn't try to call any methods on
    # a closed gateway.
    def ensure_open!
      raise "attempt to use a closed gateway" unless active?
    end

    # Fires up the gateway session's event loop within a thread, so that it
    # can run in the background. The loop will run for as long as the gateway
    # remains active.
    def initiate_event_loop!
      @active = true

      @thread = Thread.new do
        while @active
          @session_mutex.synchronize do
            @session.process(@loop_wait)
          end
          Thread.pass
        end
      end
    end

    # Grabs the next available port number and returns it.
    def next_port
      @port_mutex.synchronize do
        port = @next_port
        @next_port -= 1
        @next_port = MAX_PORT if @next_port < MIN_PORT
        port
      end
    end
end
