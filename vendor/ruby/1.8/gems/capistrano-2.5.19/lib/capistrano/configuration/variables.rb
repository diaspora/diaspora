require 'thread'

module Capistrano
  class Configuration
    module Variables
      def self.included(base) #:nodoc:
        %w(initialize respond_to? method_missing).each do |m|
          base_name = m[/^\w+/]
          punct     = m[/\W+$/]
          base.send :alias_method, "#{base_name}_without_variables#{punct}", m
          base.send :alias_method, m, "#{base_name}_with_variables#{punct}"
        end
      end

      # The hash of variables that have been defined in this configuration
      # instance.
      attr_reader :variables

      # Set a variable to the given value.
      def set(variable, *args, &block)
        if variable.to_s !~ /^[_a-z]/
          raise ArgumentError, "invalid variable `#{variable}' (variables must begin with an underscore, or a lower-case letter)"
        end

        if !block_given? && args.empty? || block_given? && !args.empty?
          raise ArgumentError, "you must specify exactly one of either a value or a block"
        end

        if args.length > 1
          raise ArgumentError, "wrong number of arguments (#{args.length} for 1)"
        end

        value = args.empty? ? block : args.first
        sym = variable.to_sym
        protect(sym) { @variables[sym] = value }
      end

      alias :[]= :set

      # Removes any trace of the given variable.
      def unset(variable)
        sym = variable.to_sym
        protect(sym) do
          @original_procs.delete(sym)
          @variables.delete(sym)
        end
      end

      # Returns true if the variable has been defined, and false otherwise.
      def exists?(variable)
        @variables.key?(variable.to_sym)
      end

      # If the variable was originally a proc value, it will be reset to it's
      # original proc value. Otherwise, this method does nothing. It returns
      # true if the variable was actually reset.
      def reset!(variable)
        sym = variable.to_sym
        protect(sym) do
          if @original_procs.key?(sym)
            @variables[sym] = @original_procs.delete(sym)
            true
          else
            false
          end
        end
      end

      # Access a named variable. If the value of the variable responds_to? :call,
      # #call will be invoked (without parameters) and the return value cached
      # and returned.
      def fetch(variable, *args)
        if !args.empty? && block_given?
          raise ArgumentError, "you must specify either a default value or a block, but not both"
        end

        sym = variable.to_sym
        protect(sym) do
          if !@variables.key?(sym)
            return args.first unless args.empty?
            return yield(variable) if block_given?
            raise IndexError, "`#{variable}' not found"
          end

          if @variables[sym].respond_to?(:call)
            @original_procs[sym] = @variables[sym]
            @variables[sym] = @variables[sym].call
          end
        end

        @variables[sym]
      end

      def [](variable)
        fetch(variable, nil)
      end

      def initialize_with_variables(*args) #:nodoc:
        initialize_without_variables(*args)
        @variables = {}
        @original_procs = {}
        @variable_locks = Hash.new { |h,k| h[k] = Mutex.new }

        set :ssh_options, {}
        set :logger, logger
      end
      private :initialize_with_variables

      def protect(variable)
        @variable_locks[variable.to_sym].synchronize { yield }
      end
      private :protect

      def respond_to_with_variables?(sym, include_priv=false) #:nodoc:
        @variables.has_key?(sym) || respond_to_without_variables?(sym, include_priv)
      end

      def method_missing_with_variables(sym, *args, &block) #:nodoc:
        if args.length == 0 && block.nil? && @variables.has_key?(sym)
          self[sym]
        else
          method_missing_without_variables(sym, *args, &block)
        end
      end
    end
  end
end