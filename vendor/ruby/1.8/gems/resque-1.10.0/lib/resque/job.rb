module Resque
  # A Resque::Job represents a unit of work. Each job lives on a
  # single queue and has an associated payload object. The payload
  # is a hash with two attributes: `class` and `args`. The `class` is
  # the name of the Ruby class which should be used to run the
  # job. The `args` are an array of arguments which should be passed
  # to the Ruby class's `perform` class-level method.
  #
  # You can manually run a job using this code:
  #
  #   job = Resque::Job.reserve(:high)
  #   klass = Resque::Job.constantize(job.payload['class'])
  #   klass.perform(*job.payload['args'])
  class Job
    include Helpers
    extend Helpers

    # Raise Resque::Job::DontPerform from a before_perform hook to
    # abort the job.
    DontPerform = Class.new(StandardError)

    # The worker object which is currently processing this job.
    attr_accessor :worker

    # The name of the queue from which this job was pulled (or is to be
    # placed)
    attr_reader :queue

    # This job's associated payload object.
    attr_reader :payload

    def initialize(queue, payload)
      @queue = queue
      @payload = payload
    end

    # Creates a job by placing it on a queue. Expects a string queue
    # name, a string class name, and an optional array of arguments to
    # pass to the class' `perform` method.
    #
    # Raises an exception if no queue or class is given.
    def self.create(queue, klass, *args)
      if !queue
        raise NoQueueError.new("Jobs must be placed onto a queue.")
      end

      if klass.to_s.empty?
        raise NoClassError.new("Jobs must be given a class.")
      end

      ret = Resque.push(queue, :class => klass.to_s, :args => args)
      Plugin.after_enqueue_hooks(klass).each do |hook|
        klass.send(hook, *args)
      end
      ret
    end

    # Removes a job from a queue. Expects a string queue name, a
    # string class name, and, optionally, args.
    #
    # Returns the number of jobs destroyed.
    #
    # If no args are provided, it will remove all jobs of the class
    # provided.
    #
    # That is, for these two jobs:
    #
    # { 'class' => 'UpdateGraph', 'args' => ['defunkt'] }
    # { 'class' => 'UpdateGraph', 'args' => ['mojombo'] }
    #
    # The following call will remove both:
    #
    #   Resque::Job.destroy(queue, 'UpdateGraph')
    #
    # Whereas specifying args will only remove the 2nd job:
    #
    #   Resque::Job.destroy(queue, 'UpdateGraph', 'mojombo')
    #
    # This method can be potentially very slow and memory intensive,
    # depending on the size of your queue, as it loads all jobs into
    # a Ruby array before processing.
    def self.destroy(queue, klass, *args)
      klass = klass.to_s
      queue = "queue:#{queue}"
      destroyed = 0

      if args.empty?
        redis.lrange(queue, 0, -1).each do |string|
          if decode(string)['class'] == klass
            destroyed += redis.lrem(queue, 0, string).to_i
          end
        end
      else
        destroyed += redis.lrem(queue, 0, encode(:class => klass, :args => args))
      end

      destroyed
    end

    # Given a string queue name, returns an instance of Resque::Job
    # if any jobs are available. If not, returns nil.
    def self.reserve(queue)
      return unless payload = Resque.pop(queue)
      new(queue, payload)
    end

    # Attempts to perform the work represented by this job instance.
    # Calls #perform on the class given in the payload with the
    # arguments given in the payload.
    def perform
      job = payload_class
      job_args = args || []
      job_was_performed = false

      before_hooks  = Plugin.before_hooks(job)
      around_hooks  = Plugin.around_hooks(job)
      after_hooks   = Plugin.after_hooks(job)
      failure_hooks = Plugin.failure_hooks(job)

      begin
        # Execute before_perform hook. Abort the job gracefully if
        # Resque::DontPerform is raised.
        begin
          before_hooks.each do |hook|
            job.send(hook, *job_args)
          end
        rescue DontPerform
          return false
        end

        # Execute the job. Do it in an around_perform hook if available.
        if around_hooks.empty?
          job.perform(*job_args)
          job_was_performed = true
        else
          # We want to nest all around_perform plugins, with the last one
          # finally calling perform
          stack = around_hooks.reverse.inject(nil) do |last_hook, hook|
            if last_hook
              lambda do
                job.send(hook, *job_args) { last_hook.call }
              end
            else
              lambda do
                job.send(hook, *job_args) do
                  result = job.perform(*job_args)
                  job_was_performed = true
                  result
                end
              end
            end
          end
          stack.call
        end

        # Execute after_perform hook
        after_hooks.each do |hook|
          job.send(hook, *job_args)
        end

        # Return true if the job was performed
        return job_was_performed

      # If an exception occurs during the job execution, look for an
      # on_failure hook then re-raise.
      rescue Object => e
        failure_hooks.each { |hook| job.send(hook, e, *job_args) }
        raise e
      end
    end

    # Returns the actual class constant represented in this job's payload.
    def payload_class
      @payload_class ||= constantize(@payload['class'])
    end

    # Returns an array of args represented in this job's payload.
    def args
      @payload['args']
    end

    # Given an exception object, hands off the needed parameters to
    # the Failure module.
    def fail(exception)
      Failure.create \
        :payload   => payload,
        :exception => exception,
        :worker    => worker,
        :queue     => queue
    end

    # Creates an identical job, essentially placing this job back on
    # the queue.
    def recreate
      self.class.create(queue, payload_class, *args)
    end

    # String representation
    def inspect
      obj = @payload
      "(Job{%s} | %s | %s)" % [ @queue, obj['class'], obj['args'].inspect ]
    end

    # Equality
    def ==(other)
      queue == other.queue &&
        payload_class == other.payload_class &&
        args == other.args
    end
  end
end
