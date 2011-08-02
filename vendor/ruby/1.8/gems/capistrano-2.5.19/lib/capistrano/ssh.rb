begin
  require 'rubygems'
  gem 'net-ssh', ">= 2.0.10"
rescue LoadError, NameError
end

require 'net/ssh'

module Capistrano
  # A helper class for dealing with SSH connections.
  class SSH
    # Patch an accessor onto an SSH connection so that we can record the server
    # definition object that defines the connection. This is useful because
    # the gateway returns connections whose "host" is 127.0.0.1, instead of
    # the host on the other side of the tunnel.
    module Server #:nodoc:
      def self.apply_to(connection, server)
        connection.extend(Server)
        connection.xserver = server
        connection
      end

      attr_accessor :xserver
    end

    # An abstraction to make it possible to connect to the server via public key
    # without prompting for the password. If the public key authentication fails
    # this will fall back to password authentication.
    #
    # +server+ must be an instance of ServerDefinition.
    #
    # If a block is given, the new session is yielded to it, otherwise the new
    # session is returned.
    #
    # If an :ssh_options key exists in +options+, it is passed to the Net::SSH
    # constructor. Values in +options+ are then merged into it, and any
    # connection information in +server+ is added last, so that +server+ info
    # takes precedence over +options+, which takes precendence over ssh_options.
    def self.connect(server, options={})
      connection_strategy(server, options) do |host, user, connection_options|
        connection = Net::SSH.start(host, user, connection_options)
        Server.apply_to(connection, server)
      end
    end

    # Abstracts the logic for establishing an SSH connection (which includes
    # testing for connection failures and retrying with a password, and so forth,
    # mostly made complicated because of the fact that some of these variables
    # might be lazily evaluated and try to do something like prompt the user,
    # which should only happen when absolutely necessary.
    #
    # This will yield the hostname, username, and a hash of connection options
    # to the given block, which should return a new connection.
    def self.connection_strategy(server, options={}, &block)
      methods = [ %w(publickey hostbased), %w(password keyboard-interactive) ]
      password_value = nil

      # construct the hash of ssh options that should be passed more-or-less
      # directly to Net::SSH. This will be the general ssh options, merged with
      # the server-specific ssh-options.
      ssh_options = (options[:ssh_options] || {}).merge(server.options[:ssh_options] || {})

      # load any SSH configuration files that were specified in the SSH options. This
      # will load from ~/.ssh/config and /etc/ssh_config by default (see Net::SSH
      # for details). Merge the explicitly given ssh_options over the top of the info
      # from the config file.
      ssh_options = Net::SSH.configuration_for(server.host, ssh_options.fetch(:config, true)).merge(ssh_options)

      # Once we've loaded the config, we don't need Net::SSH to do it again.
      ssh_options[:config] = false

      user = server.user || options[:user] || ssh_options[:username] ||
             ssh_options[:user] || ServerDefinition.default_user
      port = server.port || options[:port] || ssh_options[:port]

      # the .ssh/config file might have changed the host-name on us
      host = ssh_options.fetch(:host_name, server.host) 

      ssh_options[:port] = port if port

      # delete these, since we've determined which username to use by this point
      ssh_options.delete(:username)
      ssh_options.delete(:user)

      begin
        connection_options = ssh_options.merge(
          :password => password_value,
          :auth_methods => ssh_options[:auth_methods] || methods.shift
        )

        yield host, user, connection_options
      rescue Net::SSH::AuthenticationFailed
        raise if methods.empty? || ssh_options[:auth_methods]
        password_value = options[:password]
        retry
      end
    end
  end
end
