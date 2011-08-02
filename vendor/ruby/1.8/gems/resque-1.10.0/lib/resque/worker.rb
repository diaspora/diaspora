module Resque
  # A Resque Worker processes jobs. On platforms that support fork(2),
  # the worker will fork off a child to process each job. This ensures
  # a clean slate when beginning the next job and cuts down on gradual
  # memory growth as well as low level failures.
  #
  # It also ensures workers are always listening to signals from you,
  # their master, and can react accordingly.
  class Worker
    include Resque::Helpers
    extend Resque::Helpers

    # Whether the worker should log basic info to STDOUT
    attr_accessor :verbose

    # Whether the worker should log lots of info to STDOUT
    attr_accessor  :very_verbose

    # Boolean indicating whether this worker can or can not fork.
    # Automatically set if a fork(2) fails.
    attr_accessor :cant_fork

    attr_writer :to_s

    # Returns an array of all worker objects.
    def self.all
      Array(redis.smembers(:workers)).map { |id| find(id) }.compact
    end

    # Returns an array of all worker objects currently processing
    # jobs.
    def self.working
      names = all
      return [] unless names.any?
      names.map! { |name| "worker:#{name}" }
      redis.mapped_mget(*names).keys.map do |key|
        find key.sub("worker:", '')
      end.compact
    end

    # Returns a single worker object. Accepts a string id.
    def self.find(worker_id)
      if exists? worker_id
        queues = worker_id.split(':')[-1].split(',')
        worker = new(*queues)
        worker.to_s = worker_id
        worker
      else
        nil
      end
    end

    # Alias of `find`
    def self.attach(worker_id)
      find(worker_id)
    end

    # Given a string worker id, return a boolean indicating whether the
    # worker exists
    def self.exists?(worker_id)
      redis.sismember(:workers, worker_id)
    end

    # Workers should be initialized with an array of string queue
    # names. The order is important: a Worker will check the first
    # queue given for a job. If none is found, it will check the
    # second queue name given. If a job is found, it will be
    # processed. Upon completion, the Worker will again check the
    # first queue given, and so forth. In this way the queue list
    # passed to a Worker on startup defines the priorities of queues.
    #
    # If passed a single "*", this Worker will operate on all queues
    # in alphabetical order. Queues can be dynamically added or
    # removed without needing to restart workers using this method.
    def initialize(*queues)
      @queues = queues
      validate_queues
    end

    # A worker must be given a queue, otherwise it won't know what to
    # do with itself.
    #
    # You probably never need to call this.
    def validate_queues
      if @queues.nil? || @queues.empty?
        raise NoQueueError.new("Please give each worker at least one queue.")
      end
    end

    # This is the main workhorse method. Called on a Worker instance,
    # it begins the worker life cycle.
    #
    # The following events occur during a worker's life cycle:
    #
    # 1. Startup:   Signals are registered, dead workers are pruned,
    #               and this worker is registered.
    # 2. Work loop: Jobs are pulled from a queue and processed.
    # 3. Teardown:  This worker is unregistered.
    #
    # Can be passed an integer representing the polling frequency.
    # The default is 5 seconds, but for a semi-active site you may
    # want to use a smaller value.
    #
    # Also accepts a block which will be passed the job as soon as it
    # has completed processing. Useful for testing.
    def work(interval = 5, &block)
      $0 = "resque: Starting"
      startup

      loop do
        break if shutdown?

        if not @paused and job = reserve
          log "got: #{job.inspect}"
          run_hook :before_fork, job
          working_on job

          if @child = fork
            rand # Reseeding
            procline "Forked #{@child} at #{Time.now.to_i}"
            Process.wait
          else
            procline "Processing #{job.queue} since #{Time.now.to_i}"
            perform(job, &block)
            exit! unless @cant_fork
          end

          done_working
          @child = nil
        else
          break if interval.to_i == 0
          log! "Sleeping for #{interval.to_i}"
          procline @paused ? "Paused" : "Waiting for #{@queues.join(',')}"
          sleep interval.to_i
        end
      end

    ensure
      unregister_worker
    end

    # DEPRECATED. Processes a single job. If none is given, it will
    # try to produce one. Usually run in the child.
    def process(job = nil, &block)
      return unless job ||= reserve

      working_on job
      perform(job, &block)
    ensure
      done_working
    end

    # Processes a given job in the child.
    def perform(job)
      begin
        run_hook :after_fork, job
        job.perform
      rescue Object => e
        log "#{job.inspect} failed: #{e.inspect}"
        job.fail(e)
        failed!
      else
        log "done: #{job.inspect}"
      ensure
        yield job if block_given?
      end
    end

    # Attempts to grab a job off one of the provided queues. Returns
    # nil if no job can be found.
    def reserve
      queues.each do |queue|
        log! "Checking #{queue}"
        if job = Resque::Job.reserve(queue)
          log! "Found job on #{queue}"
          return job
        end
      end

      nil
    end

    # Returns a list of queues to use when searching for a job.
    # A splat ("*") means you want every queue (in alpha order) - this
    # can be useful for dynamically adding new queues.
    def queues
      @queues[0] == "*" ? Resque.queues.sort : @queues
    end

    # Not every platform supports fork. Here we do our magic to
    # determine if yours does.
    def fork
      @cant_fork = true if $TESTING

      return if @cant_fork

      begin
        # IronRuby doesn't support `Kernel.fork` yet
        if Kernel.respond_to?(:fork)
          Kernel.fork
        else
          raise NotImplementedError
        end
      rescue NotImplementedError
        @cant_fork = true
        nil
      end
    end

    # Runs all the methods needed when a worker begins its lifecycle.
    def startup
      enable_gc_optimizations
      register_signal_handlers
      prune_dead_workers
      run_hook :before_first_fork
      register_worker

      # Fix buffering so we can `rake resque:work > resque.log` and
      # get output from the child in there.
      $stdout.sync = true
    end

    # Enables GC Optimizations if you're running REE.
    # http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
    def enable_gc_optimizations
      if GC.respond_to?(:copy_on_write_friendly=)
        GC.copy_on_write_friendly = true
      end
    end

    # Registers the various signal handlers a worker responds to.
    #
    # TERM: Shutdown immediately, stop processing jobs.
    #  INT: Shutdown immediately, stop processing jobs.
    # QUIT: Shutdown after the current job has finished processing.
    # USR1: Kill the forked child immediately, continue processing jobs.
    # USR2: Don't process any new jobs
    # CONT: Start processing jobs again after a USR2
    def register_signal_handlers
      trap('TERM') { shutdown!  }
      trap('INT')  { shutdown!  }

      begin
        trap('QUIT') { shutdown   }
        trap('USR1') { kill_child }
        trap('USR2') { pause_processing }
        trap('CONT') { unpause_processing }
      rescue ArgumentError
        warn "Signals QUIT, USR1, USR2, and/or CONT not supported."
      end

      log! "Registered signals"
    end

    # Schedule this worker for shutdown. Will finish processing the
    # current job.
    def shutdown
      log 'Exiting...'
      @shutdown = true
    end

    # Kill the child and shutdown immediately.
    def shutdown!
      shutdown
      kill_child
    end

    # Should this worker shutdown as soon as current job is finished?
    def shutdown?
      @shutdown
    end

    # Kills the forked child immediately, without remorse. The job it
    # is processing will not be completed.
    def kill_child
      if @child
        log! "Killing child at #{@child}"
        if system("ps -o pid,state -p #{@child}")
          Process.kill("KILL", @child) rescue nil
        else
          log! "Child #{@child} not found, restarting."
          shutdown
        end
      end
    end

    # Stop processing jobs after the current one has completed (if we're
    # currently running one).
    def pause_processing
      log "USR2 received; pausing job processing"
      @paused = true
    end

    # Start processing jobs again after a pause
    def unpause_processing
      log "CONT received; resuming job processing"
      @paused = false
    end

    # Looks for any workers which should be running on this server
    # and, if they're not, removes them from Redis.
    #
    # This is a form of garbage collection. If a server is killed by a
    # hard shutdown, power failure, or something else beyond our
    # control, the Resque workers will not die gracefully and therefore
    # will leave stale state information in Redis.
    #
    # By checking the current Redis state against the actual
    # environment, we can determine if Redis is old and clean it up a bit.
    def prune_dead_workers
      all_workers = Worker.all
      known_workers = worker_pids unless all_workers.empty?
      all_workers.each do |worker|
        host, pid, queues = worker.id.split(':')
        next unless host == hostname
        next if known_workers.include?(pid)
        log! "Pruning dead worker: #{worker}"
        worker.unregister_worker
      end
    end

    # Registers ourself as a worker. Useful when entering the worker
    # lifecycle on startup.
    def register_worker
      redis.sadd(:workers, self)
      started!
    end

    # Runs a named hook, passing along any arguments.
    def run_hook(name, *args)
      return unless hook = Resque.send(name)
      msg = "Running #{name} hook"
      msg << " with #{args.inspect}" if args.any?
      log msg

      args.any? ? hook.call(*args) : hook.call
    end

    # Unregisters ourself as a worker. Useful when shutting down.
    def unregister_worker
      # If we're still processing a job, make sure it gets logged as a
      # failure.
      if (hash = processing) && !hash.empty?
        job = Job.new(hash['queue'], hash['payload'])
        # Ensure the proper worker is attached to this job, even if
        # it's not the precise instance that died.
        job.worker = self
        job.fail(DirtyExit.new)
      end

      redis.srem(:workers, self)
      redis.del("worker:#{self}")
      redis.del("worker:#{self}:started")

      Stat.clear("processed:#{self}")
      Stat.clear("failed:#{self}")
    end

    # Given a job, tells Redis we're working on it. Useful for seeing
    # what workers are doing and when.
    def working_on(job)
      job.worker = self
      data = encode \
        :queue   => job.queue,
        :run_at  => Time.now.to_s,
        :payload => job.payload
      redis.set("worker:#{self}", data)
    end

    # Called when we are done working - clears our `working_on` state
    # and tells Redis we processed a job.
    def done_working
      processed!
      redis.del("worker:#{self}")
    end

    # How many jobs has this worker processed? Returns an int.
    def processed
      Stat["processed:#{self}"]
    end

    # Tell Redis we've processed a job.
    def processed!
      Stat << "processed"
      Stat << "processed:#{self}"
    end

    # How many failed jobs has this worker seen? Returns an int.
    def failed
      Stat["failed:#{self}"]
    end

    # Tells Redis we've failed a job.
    def failed!
      Stat << "failed"
      Stat << "failed:#{self}"
    end

    # What time did this worker start? Returns an instance of `Time`
    def started
      redis.get "worker:#{self}:started"
    end

    # Tell Redis we've started
    def started!
      redis.set("worker:#{self}:started", Time.now.to_s)
    end

    # Returns a hash explaining the Job we're currently processing, if any.
    def job
      decode(redis.get("worker:#{self}")) || {}
    end
    alias_method :processing, :job

    # Boolean - true if working, false if not
    def working?
      state == :working
    end

    # Boolean - true if idle, false if not
    def idle?
      state == :idle
    end

    # Returns a symbol representing the current worker state,
    # which can be either :working or :idle
    def state
      redis.exists("worker:#{self}") ? :working : :idle
    end

    # Is this worker the same as another worker?
    def ==(other)
      to_s == other.to_s
    end

    def inspect
      "#<Worker #{to_s}>"
    end

    # The string representation is the same as the id for this worker
    # instance. Can be used with `Worker.find`.
    def to_s
      @to_s ||= "#{hostname}:#{Process.pid}:#{@queues.join(',')}"
    end
    alias_method :id, :to_s

    # chomp'd hostname of this machine
    def hostname
      @hostname ||= `hostname`.chomp
    end

    # Returns an array of string pids of all the other workers on this
    # machine. Useful when pruning dead workers on startup.
    def worker_pids
      `ps -A -o pid,command | grep [r]esque`.split("\n").map do |line|
        line.split(' ')[0]
      end
    end

    # Given a string, sets the procline ($0) and logs.
    # Procline is always in the format of:
    #   resque-VERSION: STRING
    def procline(string)
      $0 = "resque-#{Resque::Version}: #{string}"
      log! $0
    end

    # Log a message to STDOUT if we are verbose or very_verbose.
    def log(message)
      if verbose
        puts "*** #{message}"
      elsif very_verbose
        time = Time.now.strftime('%I:%M:%S %Y-%m-%d')
        puts "** [#{time}] #$$: #{message}"
      end
    end

    # Logs a very verbose message to STDOUT.
    def log!(message)
      log message if very_verbose
    end
  end
end
