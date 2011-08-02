ENV['SKIP_RAILS'] = 'true'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))

class NewRelic::Agent::WorkerLoopTest < Test::Unit::TestCase
  def setup
    @log = ""
    @logger = Logger.new(StringIO.new(@log))
    @worker_loop = NewRelic::Agent::WorkerLoop.new
    @worker_loop.stubs(:log).returns(@logger)
    @test_start_time = Time.now
  end

  def test_add_task
    @x = false
    @worker_loop.run(0) do
      @worker_loop.stop
      @x = true
    end
    assert @x
  end

  def test_density
    # This shows how the tasks stay aligned with the period and don't drift.
    count = 0
    start = Time.now
    @worker_loop.run(0.01) do
      count +=1
      if count == 3
        @worker_loop.stop
        next
      end
    end
    elapsed = Time.now - start
    assert_in_delta 0.03, elapsed, 0.02
  end
  def test_task_error__standard
    @logger.expects(:debug)
    @logger.expects(:error)
    # This loop task will run twice
    done = false
    @worker_loop.run(0) do
      @worker_loop.stop
      done = true
      raise "Standard Error Test"
    end
    assert done
  end
  class BadBoy < Exception; end

  def test_task_error__exception
    @logger.expects(:error).once
    @logger.expects(:debug).once
    @worker_loop.run(0) do
      @worker_loop.stop
      raise BadBoy, "oops"
    end
  end
  def test_task_error__server
    @logger.expects(:error).never
    @logger.expects(:debug).once
    @worker_loop.run(0) do
      @worker_loop.stop
      raise NewRelic::Agent::ServerError, "Runtime Error Test"
    end
  end
end
