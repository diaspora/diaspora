require 'capistrano/task_definition'

module Capistrano
  class Configuration
    module Namespaces
      DEFAULT_TASK = :default

      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_namespaces, :initialize
        base.send :alias_method, :initialize, :initialize_with_namespaces
      end

      # The name of this namespace. Defaults to +nil+ for the top-level
      # namespace.
      attr_reader :name

      # The parent namespace of this namespace. Returns +nil+ for the top-level
      # namespace.
      attr_reader :parent

      # The hash of tasks defined for this namespace.
      attr_reader :tasks

      # The hash of namespaces defined for this namespace.
      attr_reader :namespaces

      def initialize_with_namespaces(*args) #:nodoc:
        @name = @parent = nil
        initialize_without_namespaces(*args)
        @tasks = {}
        @namespaces = {}
      end
      private :initialize_with_namespaces

      # Returns the top-level namespace (the one with no parent).
      def top
        return parent.top if parent
        return self
      end

      # Returns the fully-qualified name of this namespace, or nil if the
      # namespace is at the top-level.
      def fully_qualified_name
        return nil if name.nil?
        [parent.fully_qualified_name, name].compact.join(":")
      end

      # Describe the next task to be defined. The given text will be attached to
      # the next task that is defined and used as its description.
      def desc(text)
        @next_description = text
      end

      # Returns the value set by the last, pending "desc" call. If +reset+ is
      # not false, the value will be reset immediately afterwards.
      def next_description(reset=false)
        @next_description
      ensure
        @next_description = nil if reset
      end

      # Open a namespace in which to define new tasks. If the namespace was
      # defined previously, it will be reopened, otherwise a new namespace
      # will be created for the given name.
      def namespace(name, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        namespace_already_defined = namespaces.key?(name)
        if all_methods.any? { |m| m.to_sym == name } && !namespace_already_defined
          thing = tasks.key?(name) ? "task" : "method"
          raise ArgumentError, "defining a namespace named `#{name}' would shadow an existing #{thing} with that name"
        end

        namespaces[name] ||= Namespace.new(name, self)
        namespaces[name].instance_eval(&block)

        # make sure any open description gets terminated
        namespaces[name].desc(nil)

        if !namespace_already_defined
          metaclass = class << self; self; end
          metaclass.send(:define_method, name) { namespaces[name] }
        end
      end

      # Describe a new task. If a description is active (see #desc), it is added
      # to the options under the <tt>:desc</tt> key. The new task is added to
      # the namespace.
      def task(name, options={}, &block)
        name = name.to_sym
        raise ArgumentError, "expected a block" unless block_given?

        task_already_defined = tasks.key?(name)
        if all_methods.any? { |m| m.to_sym == name } && !task_already_defined
          thing = namespaces.key?(name) ? "namespace" : "method"
          raise ArgumentError, "defining a task named `#{name}' would shadow an existing #{thing} with that name"
        end

        tasks[name] = TaskDefinition.new(name, self, {:desc => next_description(:reset)}.merge(options), &block)

        if !task_already_defined
          metaclass = class << self; self; end
          metaclass.send(:define_method, name) { execute_task(tasks[name]) }
        end
      end

      # Find the task with the given name, where name is the fully-qualified
      # name of the task. This will search into the namespaces and return
      # the referenced task, or nil if no such task can be found. If the name
      # refers to a namespace, the task in that namespace named "default"
      # will be returned instead, if one exists.
      def find_task(name)
        parts = name.to_s.split(/:/)
        tail = parts.pop.to_sym

        ns = self
        until parts.empty?
          next_part = parts.shift
          ns = next_part.empty? ? nil : ns.namespaces[next_part.to_sym]
          return nil if ns.nil?
        end

        if ns.namespaces.key?(tail)
          ns = ns.namespaces[tail]
          tail = DEFAULT_TASK
        end

        ns.tasks[tail]
      end

      # Given a task name, this will search the current namespace, and all
      # parent namespaces, looking for a task that matches the name, exactly.
      # It returns the task, if found, or nil, if not.
      def search_task(name)
        name = name.to_sym
        ns = self

        until ns.nil?
          return ns.tasks[name] if ns.tasks.key?(name)
          ns = ns.parent
        end

        return nil
      end

      # Returns the default task for this namespace. This will be +nil+ if
      # the namespace is at the top-level, and will otherwise return the
      # task named "default". If no such task exists, +nil+ will be returned.
      def default_task
        return nil if parent.nil?
        return tasks[DEFAULT_TASK]
      end
  
      # Returns the tasks in this namespace as an array of TaskDefinition
      # objects. If a non-false parameter is given, all tasks in all
      # namespaces under this namespace will be returned as well.
      def task_list(all=false)
        list = tasks.values
        namespaces.each { |name,space| list.concat(space.task_list(:all)) } if all
        list
      end

      private

        def all_methods
          public_methods.concat(protected_methods).concat(private_methods)
        end

        class Namespace
          def initialize(name, parent)
            @parent = parent
            @name = name
          end

          def role(*args)
            raise NotImplementedError, "roles cannot be defined in a namespace"
          end

          def respond_to?(sym, include_priv=false)
            super || parent.respond_to?(sym, include_priv)
          end

          def method_missing(sym, *args, &block)
            if parent.respond_to?(sym)
              parent.send(sym, *args, &block)
            else
              super
            end
          end

          include Capistrano::Configuration::Namespaces
          undef :desc, :next_description
        end
    end
  end
end