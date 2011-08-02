require 'capistrano/logger'

require 'capistrano/configuration/callbacks'
require 'capistrano/configuration/connections'
require 'capistrano/configuration/execution'
require 'capistrano/configuration/loading'
require 'capistrano/configuration/namespaces'
require 'capistrano/configuration/roles'
require 'capistrano/configuration/servers'
require 'capistrano/configuration/variables'

require 'capistrano/configuration/actions/file_transfer'
require 'capistrano/configuration/actions/inspect'
require 'capistrano/configuration/actions/invocation'

module Capistrano
  # Represents a specific Capistrano configuration. A Configuration instance
  # may be used to load multiple recipe files, define and describe tasks,
  # define roles, and set configuration variables.
  class Configuration
    # The logger instance defined for this configuration.
    attr_accessor :debug, :logger, :dry_run, :preserve_roles

    def initialize(options={}) #:nodoc:
      @debug = false
      @dry_run = false
      @preserve_roles = false
      @logger = Logger.new(options)
    end

    # make the DSL easier to read when using lazy evaluation via lambdas
    alias defer lambda

    # The includes must come at the bottom, since they may redefine methods
    # defined in the base class.
    include Connections, Execution, Loading, Namespaces, Roles, Servers, Variables

    # Mix in the actions
    include Actions::FileTransfer, Actions::Inspect, Actions::Invocation

    # Must mix last, because it hooks into previously defined methods
    include Callbacks
  end
end
