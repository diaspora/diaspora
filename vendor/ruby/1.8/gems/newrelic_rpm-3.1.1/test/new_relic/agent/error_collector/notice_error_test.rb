require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))
class NewRelic::Agent::ErrorCollector::NoticeErrorTest < Test::Unit::TestCase
  require 'new_relic/agent/error_collector'
  include NewRelic::Agent::ErrorCollector::NoticeError

  def test_error_params_from_options_mocked
    options = {:initial => 'options'}
    self.expects(:uri_ref_and_root).returns({:hi => 'there', :hello => 'bad'})
    self.expects(:normalized_request_and_custom_params).with({:initial => 'options'}).returns({:hello => 'world'})
    assert_equal({:hi => 'there', :hello => 'world'}, error_params_from_options(options))
  end

  module Winner
    def winner
      'yay'
    end
  end

  def test_sense_method
    object = Object.new
    object.extend(Winner)
    assert !sense_method(object, 'blab')
    assert_equal 'yay', sense_method(object, 'winner')
  end

  def test_fetch_from_options
    options = {:hello => 'world'}
    assert_equal 'world', fetch_from_options(options, :hello, '')
    assert_equal '', fetch_from_options(options, :none, '')
    assert_equal({}, options)
  end

  def test_uri_ref_and_root_default
    fake_control = mocked_control
    fake_control.expects(:root).returns('rootbeer')
    options = {}
    assert_equal({:request_referer => '', :rails_root => 'rootbeer', :request_uri => ''}, uri_ref_and_root(options))
  end

  def test_uri_ref_and_root_values
    fake_control = mocked_control
    fake_control.expects(:root).returns('rootbeer')
    options = {:uri => 'whee', :referer => 'bang'}
    assert_equal({:request_referer => 'bang', :rails_root => 'rootbeer', :request_uri => 'whee'}, uri_ref_and_root(options))
  end

  def test_custom_params_from_opts_base
    assert_equal({}, custom_params_from_opts({}))
  end

  def test_custom_params_from_opts_custom_params
    assert_equal({:foo => 'bar'}, custom_params_from_opts({:custom_params => {:foo => 'bar'}}))
  end

  def test_custom_params_from_opts_merged_params
    assert_equal({:foo => 'baz'}, custom_params_from_opts({:custom_params => {:foo => 'bar'}, :foo => 'baz'}))
  end

  def test_request_params_from_opts_positive
    fake_control = mock('control')
    self.expects(:control).returns(fake_control)
    fake_control.expects(:capture_params).returns(true)
    val = {:request_params => 'foo'}
    assert_equal('foo', request_params_from_opts(val))
    assert_equal({}, val, "should delete request_params key from hash")
  end

  def test_request_params_from_opts_negative
    fake_control = mock('control')
    self.expects(:control).returns(fake_control)
    fake_control.expects(:capture_params).returns(false)
    val = {:request_params => 'foo'}
    assert_equal(nil, request_params_from_opts(val))
    assert_equal({}, val, "should delete request_params key from hash")
  end

  def test_normalized_request_and_custom_params_base
    self.expects(:normalize_params).with(nil).returns(nil)
    self.expects(:normalize_params).with({}).returns({})
    fake_control = mock('control')
    self.expects(:control).returns(fake_control)
    fake_control.expects(:capture_params).returns(true)
    assert_equal({:request_params => nil, :custom_params => {}}, normalized_request_and_custom_params({}))
  end

  def test_extract_source_base
    @capture_source = true
    self.expects(:sense_method).with(nil, 'source_extract')
    assert_equal(nil, extract_source(nil))
  end

  def test_extract_source_disabled
    @capture_source = false
    assert_equal(nil, extract_source(mock('exception')))
  end

  def test_extract_source_with_source
    self.expects(:sense_method).with('happy', 'source_extract').returns('THE SOURCE')
    @capture_source = true
    assert_equal('THE SOURCE', extract_source('happy'))
  end

  def test_extract_stack_trace
    exception = mock('exception')
    self.expects(:sense_method).with(exception, 'original_exception')
    self.expects(:sense_method).with(exception, 'backtrace')
    assert_equal('<no stack trace>', extract_stack_trace(exception))
  end

  def test_extract_stack_trace_positive
    orig = mock('original')
    exception = mock('exception')
    self.expects(:sense_method).with(exception, 'original_exception').returns(orig)
    self.expects(:sense_method).with(orig, 'backtrace').returns('STACK STACK STACK')
    assert_equal('STACK STACK STACK', extract_stack_trace(exception))
  end

  def test_over_queue_limit_negative
    @errors = []
    assert !over_queue_limit?(nil)
  end

  def test_over_queue_limit_positive
    @errors = %w(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21)
    fake_log = mock('log')
    self.expects(:log).returns(fake_log)
    fake_log.expects(:warn).with('The error reporting queue has reached 20. The error detail for this and subsequent errors will not be transmitted to New Relic until the queued errors have been sent: hooray')
    assert over_queue_limit?('hooray')
  end

  def test_exception_info
    exception = mock('exception')
    self.expects(:sense_method).with(exception, 'file_name').returns('file_name')
    self.expects(:sense_method).with(exception, 'line_number').returns('line_number')
    self.expects(:extract_source).with(exception).returns('source')
    self.expects(:extract_stack_trace).with(exception).returns('stack_trace')
    assert_equal({:file_name => 'file_name', :line_number => 'line_number', :source => 'source', :stack_trace => 'stack_trace'},
                 exception_info(exception))
  end

  def test_add_to_error_queue_positive
    noticed_error = mock('noticed_error')
    noticed_error.expects(:message).returns('a message')
    @lock = Mutex.new
    @errors = []
    self.expects(:over_queue_limit?).with('a message').returns(false)
    add_to_error_queue(noticed_error)
    assert_equal([noticed_error], @errors)
  end

  def test_add_to_error_queue_negative
    noticed_error = mock('noticed_error')
    noticed_error.expects(:message).returns('a message')
    @lock = Mutex.new
    @errors = []
    self.expects(:over_queue_limit?).with('a message').returns(true)
    add_to_error_queue(noticed_error)
    assert_equal([], @errors)
  end

  def test_should_exit_notice_error_disabled
    error = mocked_error
    @enabled = false
    assert should_exit_notice_error?(error)
  end

  def test_should_exit_notice_error_nil
    error = nil
    @enabled = true
    self.expects(:error_is_ignored?).with(error).returns(false)
    # we increment it for the case that someone calls
    # NewRelic::Agent.notice_error(foo) # foo is nil
    # (which is probably not a good idea but is the existing api)
    self.expects(:increment_error_count!)
    assert should_exit_notice_error?(error)
  end

  def test_should_exit_notice_error_positive
    error = mocked_error
    @enabled = true
    self.expects(:error_is_ignored?).with(error).returns(true)
    assert should_exit_notice_error?(error)
  end

  def test_should_exit_notice_error_negative
    error = mocked_error
    @enabled = true
    self.expects(:error_is_ignored?).with(error).returns(false)
    self.expects(:increment_error_count!)
    assert !should_exit_notice_error?(error)
  end

  def test_filtered_error_positive
    @ignore = {'an_error' => true}
    error = mocked_error
    error_class = mock('error class')
    error.expects(:class).returns(error_class)
    error_class.expects(:name).returns('an_error')
    assert filtered_error?(error)
  end

  def test_filtered_error_negative
    @ignore = {}
    error = mocked_error
    error_class = mock('error class')
    error.expects(:class).returns(error_class)
    error_class.expects(:name).returns('an_error')
    self.expects(:filtered_by_error_filter?).with(error).returns(false)
    assert !filtered_error?(error)
  end

  def test_filtered_by_error_filter_empty
    # should return right away when there's no filter
    @ignore_filter = nil
    assert !filtered_by_error_filter?(nil)
  end

  def test_filtered_by_error_filter_positive
    error = mocked_error
    @ignore_filter = lambda { |x| assert_equal error, x; false  }
    assert filtered_by_error_filter?(error)
  end

  def test_filtered_by_error_filter_negative
    error = mocked_error
    @ignore_filter = lambda { |x| assert_equal error, x; true  }
    assert !filtered_by_error_filter?(error)
  end

  def test_error_is_ignored_positive
    error = mocked_error
    self.expects(:filtered_error?).with(error).returns(true)
    assert error_is_ignored?(error)
  end

  def test_error_is_ignored_negative
    error = mocked_error
    self.expects(:filtered_error?).with(error).returns(false)
    assert !error_is_ignored?(error)
  end

  def test_error_is_ignored_no_error
    assert !error_is_ignored?(nil), 'should not ignore nil'
  end

  private

  def mocked_error
    mock('error')
  end

  def mocked_control
    fake_control = mock('control')
    self.stubs(:control).returns(fake_control)
    fake_control
  end
end
