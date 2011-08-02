require 'capistrano/recipes/deploy/dependencies'

module Capistrano
  module Deploy
    module Strategy

      # This class defines the abstract interface for all Capistrano
      # deployment strategies. Subclasses must implement at least the
      # #deploy! method.
      class Base
        attr_reader :configuration

        # Instantiates a strategy with a reference to the given configuration.
        def initialize(config={})
          @configuration = config
        end

        # Executes the necessary commands to deploy the revision of the source
        # code identified by the +revision+ variable. Additionally, this
        # should write the value of the +revision+ variable to a file called
        # REVISION, in the base of the deployed revision. This file is used by
        # other tasks, to perform diffs and such.
        def deploy!
          raise NotImplementedError, "`deploy!' is not implemented by #{self.class.name}"
        end

        # Performs a check on the remote hosts to determine whether everything
        # is setup such that a deploy could succeed.
        def check!
          Dependencies.new(configuration) do |d|
            d.remote.directory(configuration[:releases_path]).or("`#{configuration[:releases_path]}' does not exist. Please run `cap deploy:setup'.")
            d.remote.writable(configuration[:deploy_to]).or("You do not have permissions to write to `#{configuration[:deploy_to]}'.")
            d.remote.writable(configuration[:releases_path]).or("You do not have permissions to write to `#{configuration[:releases_path]}'.")
          end
        end
          
        protected

          # This is to allow helper methods like "run" and "put" to be more
          # easily accessible to strategy implementations.
          def method_missing(sym, *args, &block)
            if configuration.respond_to?(sym)
              configuration.send(sym, *args, &block)
            else
              super
            end
          end

          # A wrapper for Kernel#system that logs the command being executed.
          def system(*args)
            cmd = args.join(' ')
            if RUBY_PLATFORM =~ /win32/
							cmd = cmd.split(/\s+/).collect {|w| w.match(/^[\w+]+:\/\//) ? w : w.gsub('/', '\\') }.join(' ') # Split command by spaces, change / by \\ unless element is a some+thing:// 
              cmd.gsub!(/^cd /,'cd /D ') # Replace cd with cd /D
              cmd.gsub!(/&& cd /,'&& cd /D ') # Replace cd with cd /D
              logger.trace "executing locally: #{cmd}"
              super(cmd)
            else
              logger.trace "executing locally: #{cmd}"
              super
            end
          end

        private

          def logger
            @logger ||= configuration[:logger] || Capistrano::Logger.new(:output => STDOUT)
          end

          # The revision to deploy. Must return a real revision identifier,
          # and not a pseudo-id.
          def revision
            configuration[:real_revision]
          end
      end

    end
  end
end
