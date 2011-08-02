require 'capistrano/configuration'

module Capistrano
  class CLI
    module Execute
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Invoke capistrano using the ARGV array as the option parameters. This
        # is what the command-line capistrano utility does.
        def execute
          parse(ARGV).execute!
        end
      end

      # Using the options build when the command-line was parsed, instantiate
      # a new Capistrano configuration, initialize it, and execute the
      # requested actions.
      #
      # Returns the Configuration instance used, if successful.
      def execute!
        config = instantiate_configuration(options)
        config.debug = options[:debug]
        config.dry_run = options[:dry_run]
        config.preserve_roles = options[:preserve_roles]
        config.logger.level = options[:verbose]

        set_pre_vars(config)
        load_recipes(config)

        config.trigger(:load)
        execute_requested_actions(config)
        config.trigger(:exit)

        config
      rescue Exception => error
        handle_error(error)
      end

      def execute_requested_actions(config)
        Array(options[:vars]).each { |name, value| config.set(name, value) }

        Array(options[:actions]).each do |action|
          config.find_and_execute_task(action, :before => :start, :after => :finish)
        end
      end

      def set_pre_vars(config) #:nodoc:
        config.set :password, options[:password]
        Array(options[:pre_vars]).each { |name, value| config.set(name, value) }
      end

      def load_recipes(config) #:nodoc:
        # load the standard recipe definition
        config.load "standard"
      
        # load systemwide config/recipe definition
        config.load(options[:sysconf]) if options[:sysconf] && File.file?(options[:sysconf])        
      
        # load user config/recipe definition
        config.load(options[:dotfile]) if options[:dotfile] && File.file?(options[:dotfile])

        Array(options[:recipes]).each { |recipe| config.load(recipe) }
      end

      # Primarily useful for testing, but subclasses of CLI could conceivably
      # override this method to return a Configuration subclass or replacement.
      def instantiate_configuration(options={}) #:nodoc:
        Capistrano::Configuration.new(options)
      end

      def handle_error(error) #:nodoc:
        case error
        when Net::SSH::AuthenticationFailed
          abort "authentication failed for `#{error.message}'"
        when Capistrano::Error
          abort(error.message)
        else raise error
        end
      end
    end
  end
end
