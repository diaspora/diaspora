require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))
class NewRelic::Agent::Agent::StartWorkerThreadTest < Test::Unit::TestCase
  require 'new_relic/agent/agent'
  include NewRelic::Agent::Agent::StartWorkerThread

  def test_deferred_work_connects
    self.expects(:catch_errors).yields
    self.expects(:connect).with('connection_options')
    @connected = true
    self.expects(:check_transaction_sampler_status)
    self.expects(:log_worker_loop_start)
    self.expects(:create_and_run_worker_loop)
    deferred_work!('connection_options')
  end

  def test_deferred_work_connect_failed
    self.expects(:catch_errors).yields
    self.expects(:connect).with('connection_options')
    @connected = false
    fake_log = mocked_log
    fake_log.expects(:debug).with("No connection.  Worker thread ending.")
    deferred_work!('connection_options')
  end

  def test_check_transaction_sampler_status_enabled
    control = mocked_control
    control.expects(:developer_mode?).returns(false)
    @should_send_samples = true
    @transaction_sampler = mock('transaction_sampler')
    @transaction_sampler.expects(:enable)
    check_transaction_sampler_status
  end

  def test_check_transaction_sampler_status_devmode
    control = mocked_control
    control.expects(:developer_mode?).returns(true)
    @should_send_samples = false
    @transaction_sampler = mock('transaction_sampler')
    @transaction_sampler.expects(:enable)
    check_transaction_sampler_status
  end

  def test_check_transaction_sampler_status_disabled
    control = mocked_control
    control.expects(:developer_mode?).returns(false)
    @should_send_samples = false
    @transaction_sampler = mock('transaction_sampler')
    @transaction_sampler.expects(:disable)
    check_transaction_sampler_status
  end

  def test_log_worker_loop_start
    @report_period = 30
    log = mocked_log
    log.expects(:info).with("Reporting performance data every 30 seconds.")
    log.expects(:debug).with("Running worker loop")
    log_worker_loop_start
  end

  def test_create_and_run_worker_loop
    @report_period = 30
    @should_send_samples = true
    wl = mock('worker loop')
    NewRelic::Agent::WorkerLoop.expects(:new).returns(wl)
    wl.expects(:run).with(30).yields
    self.expects(:save_or_transmit_data)
    create_and_run_worker_loop
  end

  def test_handle_force_restart
    # hooray for methods with no branches
    error = mock('exception')
    log = mocked_log
    error.expects(:message).returns('a message')
    log.expects(:info).with('a message')
    self.expects(:reset_stats)
    self.expects(:sleep).with(30)

    @metric_ids = 'this is not an empty hash'
    @connected = true

    handle_force_restart(error)

    assert_equal({}, @metric_ids)
    assert @connected.nil?
  end

  def test_handle_force_disconnect
    error = mock('exception')
    error.expects(:message).returns('a message')
    log = mocked_log
    log.expects(:error).with("New Relic forced this agent to disconnect (a message)")
    self.expects(:disconnect)
    handle_force_disconnect(error)
  end

  def test_handle_server_connection_problem
    error_class = mock('class of exception')
    error = mock('exception')
    log = mocked_log
    log.expects(:error).with('Unable to establish connection with the server.  Run with log level set to debug for more information.')
    error.expects(:class).returns(error_class)
    error_class.expects(:name).returns('an error class')
    error.expects(:message).returns('a message')
    error.expects(:backtrace).returns(['first line', 'second line'])
    log.expects(:debug).with("an error class: a message\nfirst line")
    self.expects(:disconnect)
    handle_server_connection_problem(error)
  end

  def test_handle_other_error
    error_class = mock('class of exception')
    error = mock('exception')
    log = mocked_log
    error.expects(:class).returns(error_class)
    error_class.expects(:name).returns('an error class')
    error.expects(:message).returns('a message')
    error.expects(:backtrace).returns(['first line', 'second line'])
    log.expects(:error).with("Terminating worker loop: an error class: a message\n  first line\n  second line")
    self.expects(:disconnect)
    handle_other_error(error)
  end

  def test_catch_errors_force_restart
    @runs = 0
    error = NewRelic::Agent::ForceRestartException.new
    # twice, because we expect it to retry the block
    self.expects(:handle_force_restart).with(error).twice
    catch_errors do
      # needed to keep it from looping infinitely in the test
      @runs += 1
      raise error unless @runs > 2
    end
    assert_equal 3, @runs, 'should retry the block when it fails'
  end

  private

  def mocked_log
    fake_log = mock('log')
    self.stubs(:log).returns(fake_log)
    fake_log
  end


  def mocked_control
    fake_control = mock('control')
    self.stubs(:control).returns(fake_control)
    fake_control
  end
end

