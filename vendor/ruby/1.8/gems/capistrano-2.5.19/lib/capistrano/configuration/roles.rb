require 'capistrano/server_definition'
require 'capistrano/role'

module Capistrano
  class Configuration
    module Roles
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_roles, :initialize
        base.send :alias_method, :initialize, :initialize_with_roles
      end

      # The hash of roles defined for this configuration. Each entry in the
      # hash points to an array of server definitions that belong in that
      # role.
      attr_reader :roles

      def initialize_with_roles(*args) #:nodoc:
        initialize_without_roles(*args)
        @roles = Hash.new { |h,k| h[k] = Role.new }
      end

      # Define a new role and its associated servers. You must specify at least
      # one host for each role. Also, you can specify additional information
      # (in the form of a Hash) which can be used to more uniquely specify the
      # subset of servers specified by this specific role definition.
      #
      # Usage:
      #
      #   role :db,  "db1.example.com", "db2.example.com"
      #   role :db,  "master.example.com", :primary => true
      #   role :app, "app1.example.com", "app2.example.com"
      #
      # You can also encode the username and port number for each host in the
      # server string, if needed:
      #
      #   role :web,  "www@web1.example.com"
      #   role :file, "files.example.com:4144"
      #   role :db,   "admin@db3.example.com:1234"
      #
      # Lastly, username and port number may be passed as options, if that is
      # preferred; note that the options apply to all servers defined in
      # that call to "role":
      #
      #   role :web, "web2", "web3", :user => "www", :port => 2345
      def role(which, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        which = which.to_sym

        # The roles Hash is defined so that unrecognized keys always auto-initialize
        # to a new Role instance (see the assignment in the initialize_with_roles method,
        # above). However, we explicitly assign here so that role declarations will
        # vivify the role object even if there are no server arguments. (Otherwise,
        # role(:app) won't actually instantiate a Role object for :app.)
        roles[which] ||= Role.new

        roles[which].push(block, options) if block_given?
        args.each { |host| roles[which] << ServerDefinition.new(host, options) }
      end

      # An alternative way to associate servers with roles. If you have a server
      # that participates in multiple roles, this can be a DRYer way to describe
      # the relationships. Pass the host definition as the first parameter, and
      # the roles as the remaining parameters:
      #
      #   server "master.example.com", :web, :app
      def server(host, *roles)
        options = roles.last.is_a?(Hash) ? roles.pop : {}
        raise ArgumentError, "you must associate a server with at least one role" if roles.empty?
        roles.each { |name| role(name, host, options) }
      end
    end
  end
end
