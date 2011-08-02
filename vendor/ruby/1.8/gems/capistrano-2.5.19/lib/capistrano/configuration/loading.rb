module Capistrano
  class Configuration
    module Loading
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_loading, :initialize
        base.send :alias_method, :initialize, :initialize_with_loading
        base.extend ClassMethods
      end

      module ClassMethods
        # Used by third-party task bundles to identify the capistrano
        # configuration that is loading them. Its return value is not reliable
        # in other contexts. If +require_config+ is not false, an exception
        # will be raised if the current configuration is not set.
        def instance(require_config=false)
          config = Thread.current[:capistrano_configuration]
          if require_config && config.nil?
            raise LoadError, "Please require this file from within a Capistrano recipe"
          end
          config
        end

        # Used internally by Capistrano to specify the current configuration
        # before loading a third-party task bundle.
        def instance=(config)
          Thread.current[:capistrano_configuration] = config
        end

        # Used internally by Capistrano to track which recipes have been loaded
        # via require, so that they may be successfully reloaded when require
        # is called again.
        def recipes_per_feature
          @recipes_per_feature ||= {}
        end

        # Used internally to determine what the current "feature" being
        # required is. This is used to track which files load which recipes
        # via require.
        def current_feature
          Thread.current[:capistrano_current_feature]
        end

        # Used internally to specify the current file being required, so that
        # any recipes loaded by that file can be remembered. This allows
        # recipes loaded via require to be correctly reloaded in different
        # Configuration instances in the same Ruby instance.
        def current_feature=(feature)
          Thread.current[:capistrano_current_feature] = feature
        end
      end

      # The load paths used for locating recipe files.
      attr_reader :load_paths

      def initialize_with_loading(*args) #:nodoc:
        initialize_without_loading(*args)
        @load_paths = [".", File.expand_path(File.join(File.dirname(__FILE__), "../recipes"))]
        @loaded_features = []
      end
      private :initialize_with_loading

      # Load a configuration file or string into this configuration.
      #
      # Usage:
      #
      #   load("recipe"):
      #     Look for and load the contents of 'recipe.rb' into this
      #     configuration.
      #
      #   load(:file => "recipe"):
      #     same as above
      #
      #   load(:string => "set :scm, :subversion"):
      #     Load the given string as a configuration specification.
      #
      #   load { ... }
      #     Load the block in the context of the configuration.
      def load(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}

        if block
          raise ArgumentError, "loading a block requires 0 arguments" unless options.empty? && args.empty?
          load(:proc => block)

        elsif args.any?
          args.each { |arg| load options.merge(:file => arg) }

        elsif options[:file]
          load_from_file(options[:file], options[:name])

        elsif options[:string]
          remember_load(options) unless options[:reloading]
          instance_eval(options[:string], options[:name] || "<eval>")

        elsif options[:proc]
          remember_load(options) unless options[:reloading]
          instance_eval(&options[:proc])

        else
          raise ArgumentError, "don't know how to load #{options.inspect}"
        end
      end

      # Require another file. This is identical to the standard require method,
      # with the exception that it sets the receiver as the "current" configuration
      # so that third-party task bundles can include themselves relative to
      # that configuration.
      #
      # This is a bit more complicated than an initial review would seem to
      # necessitate, but the use case that complicates things is this: An
      # advanced user wants to embed capistrano, and needs to instantiate
      # more than one capistrano configuration at a time. They also want each
      # configuration to require a third-party capistrano extension. Using a
      # naive require implementation, this would allow the first configuration
      # to successfully load the third-party extension, but the require would
      # fail for the second configuration because the extension has already
      # been loaded.
      #
      # To work around this, we do a few things:
      #
      # 1. Each time a 'require' is invoked inside of a capistrano recipe,
      #    we remember the arguments (see "current_feature").
      # 2. Each time a 'load' is invoked inside of a capistrano recipe, and
      #    "current_feature" is not nil (meaning we are inside of a pending
      #    require) we remember the options (see "remember_load" and
      #    "recipes_per_feature").
      # 3. Each time a 'require' is invoked inside of a capistrano recipe,
      #    we check to see if this particular configuration has ever seen these
      #    arguments to require (see @loaded_features), and if not, we proceed
      #    as if the file had never been required. If the superclass' require
      #    returns false (meaning, potentially, that the file has already been
      #    required), then we look in the recipes_per_feature collection and
      #    load any remembered recipes from there.
      #
      # It's kind of a bear, but it works, and works transparently. Note that
      # a simpler implementation would just muck with $", allowing files to be
      # required multiple times, but that will cause warnings (and possibly
      # errors) if the file to be required contains constant definitions and
      # such, alongside (or instead of) capistrano recipe definitions.
      def require(*args) #:nodoc:
        # look to see if this specific configuration instance has ever seen
        # these arguments to require before
        if @loaded_features.include?(args)
          return false 
        end
        
        @loaded_features << args
        begin
          original_instance, self.class.instance = self.class.instance, self
          original_feature, self.class.current_feature = self.class.current_feature, args

          result = super
          if !result # file has been required previously, load up the remembered recipes
            list = self.class.recipes_per_feature[args] || []
            list.each { |options| load(options.merge(:reloading => true)) }
          end

          return result
        ensure
          # restore the original, so that require's can be nested
          self.class.instance = original_instance
          self.class.current_feature = original_feature
        end
      end

      private

        # Load a recipe from the named file. If +name+ is given, the file will
        # be reported using that name.
        def load_from_file(file, name=nil)
          file = find_file_in_load_path(file) unless File.file?(file)
          load :string => File.read(file), :name => name || file
        end

        def find_file_in_load_path(file)
          load_paths.each do |path|
            ["", ".rb"].each do |ext|
              name = File.join(path, "#{file}#{ext}")
              return name if File.file?(name)
            end
          end

          raise LoadError, "no such file to load -- #{file}"
        end

        # If a file is being required, the options associated with loading a
        # recipe are remembered in the recipes_per_feature archive under the
        # name of the file currently being required.
        def remember_load(options)
          if self.class.current_feature
            list = (self.class.recipes_per_feature[self.class.current_feature] ||= [])
            list << options
          end
        end
    end
  end
end
