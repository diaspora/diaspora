require 'capistrano'
require 'capistrano/cli/execute'
require 'capistrano/cli/help'
require 'capistrano/cli/options'
require 'capistrano/cli/ui'

module Capistrano
  # The CLI class encapsulates the behavior of capistrano when it is invoked
  # as a command-line utility. This allows other programs to embed Capistrano
  # and preserve its command-line semantics.
  class CLI
    # The array of (unparsed) command-line options
    attr_reader :args

    # Create a new CLI instance using the given array of command-line parameters
    # to initialize it. By default, +ARGV+ is used, but you can specify a
    # different set of parameters (such as when embedded cap in a program):
    #
    #   require 'capistrano/cli'
    #   Capistrano::CLI.parse(%W(-vvvv -f config/deploy update_code)).execute!
    #
    # Note that you can also embed cap directly by creating a new Configuration
    # instance and setting it up, The above snippet, redone using the 
    # Configuration class directly, would look like:
    #
    #   require 'capistrano'
    #   require 'capistrano/cli'
    #   config = Capistrano::Configuration.new
    #   config.logger.level = Capistrano::Logger::TRACE
    #   config.set(:password) { Capistrano::CLI.password_prompt }
    #   config.load "config/deploy"
    #   config.update_code
    #
    # There may be times that you want/need the additional control offered by
    # manipulating the Configuration directly, but generally interfacing with
    # the CLI class is recommended.
    def initialize(args)
      @args = args.dup
      $stdout.sync = true # so that Net::SSH prompts show up
    end

    # Mix-in the actual behavior
    include Execute, Options, UI
    include Help # needs to be included last, because it overrides some methods

  end
end
