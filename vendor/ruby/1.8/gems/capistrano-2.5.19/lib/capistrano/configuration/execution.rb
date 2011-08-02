require 'capistrano/errors'

module Capistrano
  class Configuration
    module Execution
      def self.included(base) #:nodoc:
        base.send :alias_method, :initialize_without_execution, :initialize
        base.send :alias_method, :initialize, :initialize_with_execution
      end

      # A struct for representing a single instance of an invoked task.
      TaskCallFrame = Struct.new(:task, :rollback)

      def initialize_with_execution(*args) #:nodoc:
        initialize_without_execution(*args)
      end
      private :initialize_with_execution

      # Returns true if there is a transaction currently active.
      def transaction?
        !rollback_requests.nil?
      end

      # The call stack of the tasks. The currently executing task may inspect
      # this to see who its caller was. The current task is always the last
      # element of this stack.
      def task_call_frames
        Thread.current[:task_call_frames] ||= []
      end
      
      
      # The stack of tasks that have registered rollback handlers within the
      # current transaction. If this is nil, then there is no transaction
      # that is currently active.
      def rollback_requests
        Thread.current[:rollback_requests]
      end

      def rollback_requests=(rollback_requests)
        Thread.current[:rollback_requests] = rollback_requests
      end

      # Invoke a set of tasks in a transaction. If any task fails (raises an
      # exception), all tasks executed within the transaction are inspected to
      # see if they have an associated on_rollback hook, and if so, that hook
      # is called.
      def transaction
        raise ArgumentError, "expected a block" unless block_given?
        raise ScriptError, "transaction must be called from within a task" if task_call_frames.empty?

        return yield if transaction?

        logger.info "transaction: start"
        begin
          self.rollback_requests = []
          yield
          logger.info "transaction: commit"
        rescue Object => e
          rollback!
          raise
        ensure
          self.rollback_requests = nil if Thread.main == Thread.current
        end
      end

      # Specifies an on_rollback hook for the currently executing task. If this
      # or any subsequent task then fails, and a transaction is active, this
      # hook will be executed.
      def on_rollback(&block)
        if transaction?
          # don't note a new rollback request if one has already been set
          rollback_requests << task_call_frames.last unless task_call_frames.last.rollback
          task_call_frames.last.rollback = block
        end
      end

      # Returns the TaskDefinition object for the currently executing task.
      # It returns nil if there is no task being executed.
      def current_task
        return nil if task_call_frames.empty?
        task_call_frames.last.task
      end

      # Executes the task with the given name, without invoking any associated
      # callbacks.
      def execute_task(task)
        logger.debug "executing `#{task.fully_qualified_name}'"
        push_task_call_frame(task)
        invoke_task_directly(task)
      ensure
        pop_task_call_frame
      end

      # Attempts to locate the task at the given fully-qualified path, and
      # execute it. If no such task exists, a Capistrano::NoSuchTaskError will
      # be raised.
      def find_and_execute_task(path, hooks={})
        task = find_task(path) or raise NoSuchTaskError, "the task `#{path}' does not exist"

        trigger(hooks[:before], task) if hooks[:before]
        result = execute_task(task)
        trigger(hooks[:after], task) if hooks[:after]

        result
      end

    protected

      def rollback!
        return if Thread.current[:rollback_requests].nil?
        Thread.current[:rolled_back] = true
   
        # throw the task back on the stack so that roles are properly
        # interpreted in the scope of the task in question.
        rollback_requests.reverse.each do |frame|
          begin
            push_task_call_frame(frame.task)
            logger.important "rolling back", frame.task.fully_qualified_name
            frame.rollback.call
          rescue Object => e
            logger.info "exception while rolling back: #{e.class}, #{e.message}", frame.task.fully_qualified_name
          ensure
            pop_task_call_frame
          end
        end
      end

      def push_task_call_frame(task)
        frame = TaskCallFrame.new(task)
        task_call_frames.push frame
      end

      def pop_task_call_frame
        task_call_frames.pop
      end

      # Invokes the task's body directly, without setting up the call frame.
      def invoke_task_directly(task)
        task.namespace.instance_eval(&task.body)
      end
    end
  end
end