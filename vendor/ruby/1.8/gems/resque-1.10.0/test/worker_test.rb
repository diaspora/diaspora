require File.dirname(__FILE__) + '/test_helper'

context "Resque::Worker" do
  setup do
    Resque.redis.flushall

    Resque.before_first_fork = nil
    Resque.before_fork = nil
    Resque.after_fork = nil

    @worker = Resque::Worker.new(:jobs)
    Resque::Job.create(:jobs, SomeJob, 20, '/tmp')
  end

  test "can fail jobs" do
    Resque::Job.create(:jobs, BadJob)
    @worker.work(0)
    assert_equal 1, Resque::Failure.count
  end

  test "failed jobs report exception and message" do
    Resque::Job.create(:jobs, BadJobWithSyntaxError)
    @worker.work(0)
    assert_equal('SyntaxError', Resque::Failure.all['exception'])
    assert_equal('Extra Bad job!', Resque::Failure.all['error'])
  end

  test "fails uncompleted jobs on exit" do
    job = Resque::Job.new(:jobs, [GoodJob, "blah"])
    @worker.working_on(job)
    @worker.unregister_worker
    assert_equal 1, Resque::Failure.count
  end

  test "can peek at failed jobs" do
    10.times { Resque::Job.create(:jobs, BadJob) }
    @worker.work(0)
    assert_equal 10, Resque::Failure.count

    assert_equal 10, Resque::Failure.all(0, 20).size
  end

  test "can clear failed jobs" do
    Resque::Job.create(:jobs, BadJob)
    @worker.work(0)
    assert_equal 1, Resque::Failure.count
    Resque::Failure.clear
    assert_equal 0, Resque::Failure.count
  end

  test "catches exceptional jobs" do
    Resque::Job.create(:jobs, BadJob)
    Resque::Job.create(:jobs, BadJob)
    @worker.process
    @worker.process
    @worker.process
    assert_equal 2, Resque::Failure.count
  end

  test "can work on multiple queues" do
    Resque::Job.create(:high, GoodJob)
    Resque::Job.create(:critical, GoodJob)

    worker = Resque::Worker.new(:critical, :high)

    worker.process
    assert_equal 1, Resque.size(:high)
    assert_equal 0, Resque.size(:critical)

    worker.process
    assert_equal 0, Resque.size(:high)
  end

  test "can work on all queues" do
    Resque::Job.create(:high, GoodJob)
    Resque::Job.create(:critical, GoodJob)
    Resque::Job.create(:blahblah, GoodJob)

    worker = Resque::Worker.new("*")

    worker.work(0)
    assert_equal 0, Resque.size(:high)
    assert_equal 0, Resque.size(:critical)
    assert_equal 0, Resque.size(:blahblah)
  end

  test "processes * queues in alphabetical order" do
    Resque::Job.create(:high, GoodJob)
    Resque::Job.create(:critical, GoodJob)
    Resque::Job.create(:blahblah, GoodJob)

    worker = Resque::Worker.new("*")
    processed_queues = []

    worker.work(0) do |job|
      processed_queues << job.queue
    end

    assert_equal %w( jobs high critical blahblah ).sort, processed_queues
  end

  test "has a unique id" do
    assert_equal "#{`hostname`.chomp}:#{$$}:jobs", @worker.to_s
  end

  test "complains if no queues are given" do
    assert_raise Resque::NoQueueError do
      Resque::Worker.new
    end
  end

  test "fails if a job class has no `perform` method" do
    worker = Resque::Worker.new(:perform_less)
    Resque::Job.create(:perform_less, Object)

    assert_equal 0, Resque::Failure.count
    worker.work(0)
    assert_equal 1, Resque::Failure.count
  end

  test "inserts itself into the 'workers' list on startup" do
    @worker.work(0) do
      assert_equal @worker, Resque.workers[0]
    end
  end

  test "removes itself from the 'workers' list on shutdown" do
    @worker.work(0) do
      assert_equal @worker, Resque.workers[0]
    end

    assert_equal [], Resque.workers
  end

  test "removes worker with stringified id" do
    @worker.work(0) do
      worker_id = Resque.workers[0].to_s
      Resque.remove_worker(worker_id)
      assert_equal [], Resque.workers
    end
  end

  test "records what it is working on" do
    @worker.work(0) do
      task = @worker.job
      assert_equal({"args"=>[20, "/tmp"], "class"=>"SomeJob"}, task['payload'])
      assert task['run_at']
      assert_equal 'jobs', task['queue']
    end
  end

  test "clears its status when not working on anything" do
    @worker.work(0)
    assert_equal Hash.new, @worker.job
  end

  test "knows when it is working" do
    @worker.work(0) do
      assert @worker.working?
    end
  end

  test "knows when it is idle" do
    @worker.work(0)
    assert @worker.idle?
  end

  test "knows who is working" do
    @worker.work(0) do
      assert_equal [@worker], Resque.working
    end
  end

  test "keeps track of how many jobs it has processed" do
    Resque::Job.create(:jobs, BadJob)
    Resque::Job.create(:jobs, BadJob)

    3.times do
      job = @worker.reserve
      @worker.process job
    end
    assert_equal 3, @worker.processed
  end

  test "keeps track of how many failures it has seen" do
    Resque::Job.create(:jobs, BadJob)
    Resque::Job.create(:jobs, BadJob)

    3.times do
      job = @worker.reserve
      @worker.process job
    end
    assert_equal 2, @worker.failed
  end

  test "stats are erased when the worker goes away" do
    @worker.work(0)
    assert_equal 0, @worker.processed
    assert_equal 0, @worker.failed
  end

  test "knows when it started" do
    time = Time.now
    @worker.work(0) do
      assert_equal time.to_s, @worker.started.to_s
    end
  end

  test "knows whether it exists or not" do
    @worker.work(0) do
      assert Resque::Worker.exists?(@worker)
      assert !Resque::Worker.exists?('blah-blah')
    end
  end

  test "sets $0 while working" do
    @worker.work(0) do
      ver = Resque::Version
      assert_equal "resque-#{ver}: Processing jobs since #{Time.now.to_i}", $0
    end
  end

  test "can be found" do
    @worker.work(0) do
      found = Resque::Worker.find(@worker.to_s)
      assert_equal @worker.to_s, found.to_s
      assert found.working?
      assert_equal @worker.job, found.job
    end
  end

  test "doesn't find fakes" do
    @worker.work(0) do
      found = Resque::Worker.find('blah-blah')
      assert_equal nil, found
    end
  end

  test "cleans up dead worker info on start (crash recovery)" do
    # first we fake out two dead workers
    workerA = Resque::Worker.new(:jobs)
    workerA.instance_variable_set(:@to_s, "#{`hostname`.chomp}:1:jobs")
    workerA.register_worker

    workerB = Resque::Worker.new(:high, :low)
    workerB.instance_variable_set(:@to_s, "#{`hostname`.chomp}:2:high,low")
    workerB.register_worker

    assert_equal 2, Resque.workers.size

    # then we prune them
    @worker.work(0) do
      assert_equal 1, Resque.workers.size
    end
  end

  test "Processed jobs count" do
    @worker.work(0)
    assert_equal 1, Resque.info[:processed]
  end

  test "Will call a before_first_fork hook only once" do
    Resque.redis.flushall
    $BEFORE_FORK_CALLED = 0
    Resque.before_first_fork = Proc.new { $BEFORE_FORK_CALLED += 1 }
    workerA = Resque::Worker.new(:jobs)
    Resque::Job.create(:jobs, SomeJob, 20, '/tmp')

    assert_equal 0, $BEFORE_FORK_CALLED

    workerA.work(0)
    assert_equal 1, $BEFORE_FORK_CALLED

    # TODO: Verify it's only run once. Not easy.
#     workerA.work(0)
#     assert_equal 1, $BEFORE_FORK_CALLED
  end

  test "Will call a before_fork hook before forking" do
    Resque.redis.flushall
    $BEFORE_FORK_CALLED = false
    Resque.before_fork = Proc.new { $BEFORE_FORK_CALLED = true }
    workerA = Resque::Worker.new(:jobs)

    assert !$BEFORE_FORK_CALLED
    Resque::Job.create(:jobs, SomeJob, 20, '/tmp')
    workerA.work(0)
    assert $BEFORE_FORK_CALLED
  end

  test "Will call an after_fork hook after forking" do
    Resque.redis.flushall
    $AFTER_FORK_CALLED = false
    Resque.after_fork = Proc.new { $AFTER_FORK_CALLED = true }
    workerA = Resque::Worker.new(:jobs)

    assert !$AFTER_FORK_CALLED
    Resque::Job.create(:jobs, SomeJob, 20, '/tmp')
    workerA.work(0)
    assert $AFTER_FORK_CALLED
  end
end
