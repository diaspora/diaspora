require 'socket'
require 'net/ssh/proxy/errors'
require 'net/ssh/ruby_compat'

module Net; module SSH; module Proxy

  # An implementation of a command proxy. To use it, instantiate it,
  # then pass the instantiated object via the :proxy key to
  # Net::SSH.start:
  #
  #   require 'net/ssh/proxy/command'
  #
  #   proxy = Net::SSH::Proxy::Command.new('ssh relay nc %h %p')
  #   Net::SSH.start('host', 'user', :proxy => proxy) do |ssh|
  #     ...
  #   end
  class Command

    # The command line template
    attr_reader :command_line_template

    # The command line for the session
    attr_reader :command_line

    # Create a new socket factory that tunnels via a command executed
    # with the user's shell, which is composed from the given command
    # template.  In the command template, `%h' will be substituted by
    # the host name to connect and `%p' by the port.
    def initialize(command_line_template)
      @command_line_template = command_line_template
      @command_line = nil
    end

    # Return a new socket connected to the given host and port via the
    # proxy that was requested when the socket factory was instantiated.
    def open(host, port)
      command_line = @command_line_template.gsub(/%(.)/) {
        case $1
        when 'h'
          host
        when 'p'
          port.to_s
        when '%'
          '%'
        else
          raise ArgumentError, "unknown key: #{$1}"
        end
      }
      begin
        io = IO.popen(command_line, "r+")
        if result = Net::SSH::Compat.io_select([io], nil, [io], 60)
          if result.last.any?
            raise "command failed"
          end
        else
          raise "command timed out"
        end
      rescue => e
        raise ConnectError, "#{e}: #{command_line}"
      end
      @command_line = command_line
      class << io
        def send(data, flag)
          write_nonblock(data)
        end

        def recv(size)
          read_nonblock(size)
        end
      end
      io
    end
  end

end; end; end
