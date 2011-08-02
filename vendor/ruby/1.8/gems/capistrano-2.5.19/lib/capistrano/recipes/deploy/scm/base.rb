module Capistrano
  module Deploy
    module SCM

      # The ancestor class for all Capistrano SCM implementations. It provides
      # minimal infrastructure for subclasses to build upon and override.
      #
      # Note that subclasses that implement this abstract class only return
      # the commands that need to be executed--they do not execute the commands
      # themselves. In this way, the deployment method may execute the commands
      # either locally or remotely, as necessary.
      class Base
        class << self
          # If no parameters are given, it returns the current configured
          # name of the command-line utility of this SCM. If a parameter is
          # given, the defeault command is set to that value.
          def default_command(value=nil)
            if value
              @default_command = value
            else
              @default_command
            end
          end
        end

        # Wraps an SCM instance and forces all messages sent to it to be
        # relayed to the underlying SCM instance, in "local" mode. See
        # Base#local.
        class LocalProxy
          def initialize(scm)
            @scm = scm
          end

          def method_missing(sym, *args, &block)
            @scm.local { return @scm.send(sym, *args, &block) }
          end
        end

        # The options available for this SCM instance to reference. Should be
        # treated like a hash.
        attr_reader :configuration

        # Creates a new SCM instance with the given configuration options.
        def initialize(configuration={})
          @configuration = configuration
        end

        # Returns a proxy that wraps the SCM instance and forces it to operate
        # in "local" mode, which changes how variables are looked up in the
        # configuration. Normally, if the value of a variable "foo" is needed,
        # it is queried for in the configuration as "foo". However, in "local"
        # mode, first "local_foo" would be looked for, and only if it is not
        # found would "foo" be used. This allows for both (e.g.) "scm_command"
        # and "local_scm_command" to be set, if the two differ.
        #
        # Alternatively, it may be called with a block, and for the duration of
        # the block, all requests on this configuration object will be
        # considered local.
        def local
          if block_given?
            begin
              saved, @local_mode = @local_mode, true
              yield
            ensure
              @local_mode = saved
            end
          else
            LocalProxy.new(self)
          end
        end

        # Returns true if running in "local" mode. See #local.
        def local?
          @local_mode
        end

        # Returns the string used to identify the latest revision in the
        # repository. This will be passed as the "revision" parameter of
        # the methods below.
        def head
          raise NotImplementedError, "`head' is not implemented by #{self.class.name}"
        end

        # Checkout a copy of the repository, at the given +revision+, to the
        # given +destination+. The checkout is suitable for doing development
        # work in, e.g. allowing subsequent commits and updates.
        def checkout(revision, destination)
          raise NotImplementedError, "`checkout' is not implemented by #{self.class.name}"
        end

        # Resynchronize the working copy in +destination+ to the specified
        # +revision+.
        def sync(revision, destination)
          raise NotImplementedError, "`sync' is not implemented by #{self.class.name}"
        end

        # Compute the difference between the two revisions, +from+ and +to+.
        def diff(from, to=nil)
          raise NotImplementedError, "`diff' is not implemented by #{self.class.name}"
        end

        # Return a log of all changes between the two specified revisions,
        # +from+ and +to+, inclusive.
        def log(from, to=nil)
          raise NotImplementedError, "`log' is not implemented by #{self.class.name}"
        end

        # If the given revision represents a "real" revision, this should
        # simply return the revision value. If it represends a pseudo-revision
        # (like Subversions "HEAD" identifier), it should yield a string
        # containing the commands that, when executed will return a string
        # that this method can then extract the real revision from.
        def query_revision(revision)
          raise NotImplementedError, "`query_revision' is not implemented by #{self.class.name}"
        end

        # Returns the revision number immediately following revision, if at
        # all possible. A block should always be passed to this method, which
        # accepts a command to invoke and returns the result, although a
        # particular SCM's implementation is not required to invoke the block.
        #
        # By default, this method simply returns the revision itself. If a
        # particular SCM is able to determine a subsequent revision given a
        # revision identifier, it should override this method.
        def next_revision(revision)
          revision
        end

        # Should analyze the given text and determine whether or not a
        # response is expected, and if so, return the appropriate response.
        # If no response is expected, return nil. The +state+ parameter is a
        # hash that may be used to preserve state between calls. This method
        # is used to define how Capistrano should respond to common prompts
        # and messages from the SCM, like password prompts and such. By
        # default, the output is simply displayed.
        def handle_data(state, stream, text)
          logger.info "[#{stream}] #{text}"
          nil
        end

        # Returns the name of the command-line utility for this SCM. It first
        # looks at the :scm_command variable, and if it does not exist, it
        # then falls back to whatever was defined by +default_command+.
        #
        # If scm_command is set to :default, the default_command will be
        # returned.
        def command
          command = variable(:scm_command)
          command = nil if command == :default
          command || default_command
        end

        # A helper method that can be used to define SCM commands naturally.
        # It returns a single string with all arguments joined by spaces,
        # with the scm command prefixed onto it.
        def scm(*args)
          [command, *args].compact.join(" ")
        end

        private

          # A helper for accessing variable values, which takes into
          # consideration the current mode ("normal" vs. "local").
          def variable(name)
            if local? && configuration.exists?("local_#{name}".to_sym)
              return configuration["local_#{name}".to_sym]
            else
              configuration[name]
            end
          end

          # A reference to a Logger instance that the SCM can use to log
          # activity.
          def logger
            @logger ||= variable(:logger) || Capistrano::Logger.new(:output => STDOUT)
          end

          # A helper for accessing the default command name for this SCM. It
          # simply delegates to the class' +default_command+ method.
          def default_command
            self.class.default_command
          end

          # A convenience method for accessing the declared repository value.
          def repository
            variable(:repository)
          end

          def arguments
            variable(:scm_arguments)
          end
      end

    end
  end
end
