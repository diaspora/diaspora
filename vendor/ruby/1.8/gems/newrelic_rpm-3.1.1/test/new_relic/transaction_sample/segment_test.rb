require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))
require 'new_relic/transaction_sample/segment'
class NewRelic::TransactionSample::SegmentTest < Test::Unit::TestCase
  def test_segment_creation
    # basic smoke test
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal NewRelic::TransactionSample::Segment, s.class
  end

  def test_readers
    t = Time.now
    s = NewRelic::TransactionSample::Segment.new(t, 'Custom/test/metric', nil)
    assert_equal(t, s.entry_timestamp)
    assert_equal(nil, s.exit_timestamp)
    assert_equal(nil, s.parent_segment)
    assert_equal('Custom/test/metric', s.metric_name)
    assert_equal(s.object_id, s.segment_id)
  end

  def test_end_trace
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    t = Time.now
    s.end_trace(t)
    assert_equal(t, s.exit_timestamp)
  end

  def test_add_called_segment
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal [], s.called_segments
    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    s.add_called_segment(fake_segment)
    assert_equal([fake_segment], s.called_segments)
  end

  def test_to_s
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.expects(:to_debug_str).with(0)
    s.to_s
  end

  def test_to_json
    t = Time.now
    s = NewRelic::TransactionSample::Segment.new(t, 'Custom/test/metric', nil)
    assert_equal({ :entry_timestamp => t, :exit_timestamp => nil, :metric_name => 'Custom/test/metric', :segment_id => s.object_id }.to_json, s.to_json)
  end

  def test_path_string
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal("Custom/test/metric[]", s.path_string)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:path_string).returns('Custom/other/metric[]')


    s.add_called_segment(fake_segment)
    assert_equal("Custom/test/metric[Custom/other/metric[]]", s.path_string)
  end

  def test_to_s_compact
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal("Custom/test/metric", s.to_s_compact)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:to_s_compact).returns('Custom/other/metric')
    s.add_called_segment(fake_segment)

    assert_equal("Custom/test/metric{Custom/other/metric}", s.to_s_compact)
  end

  def test_to_debug_str_basic
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n<<  n/a Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_with_params
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    s.params = {:whee => 'a param'}
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n    -whee            : a param\n<<  n/a Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_closed
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    s.end_trace(0.1)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n<< 100 ms Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_closed_with_nonnumeric
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    s.end_trace("0.1")
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n<< 0.1 Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_one_child
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    s.add_called_segment(NewRelic::TransactionSample::Segment.new(0.1, 'Custom/test/other', nil))
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/other \n  <<  n/a Custom/test/other\n<<  n/a Custom/test/metric\n", s.to_debug_str(0))
    # try closing it
    s.called_segments.first.end_trace(0.15)
    s.end_trace(0.2)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/other \n  << 150 ms Custom/test/other\n<< 200 ms Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_multichild
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    s.add_called_segment(NewRelic::TransactionSample::Segment.new(0.1, 'Custom/test/other', nil))
    s.add_called_segment(NewRelic::TransactionSample::Segment.new(0.11, 'Custom/test/extra', nil))
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/other \n  <<  n/a Custom/test/other\n  >> 110 ms [Segment] Custom/test/extra \n  <<  n/a Custom/test/extra\n<<  n/a Custom/test/metric\n", s.to_debug_str(0))
    ending = 0.12
    s.called_segments.each { |x| x.end_trace(ending += 0.01) }
    s.end_trace(0.2)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/other \n  << 130 ms Custom/test/other\n  >> 110 ms [Segment] Custom/test/extra \n  << 140 ms Custom/test/extra\n<< 200 ms Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_to_debug_str_nested
    inner = NewRelic::TransactionSample::Segment.new(0.2, 'Custom/test/inner', nil)
    middle = NewRelic::TransactionSample::Segment.new(0.1, 'Custom/test/middle', nil)
    s = NewRelic::TransactionSample::Segment.new(0.0, 'Custom/test/metric', nil)
    middle.add_called_segment(inner)
    s.add_called_segment(middle)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/middle \n    >> 200 ms [Segment] Custom/test/inner \n    <<  n/a Custom/test/inner\n  <<  n/a Custom/test/middle\n<<  n/a Custom/test/metric\n", s.to_debug_str(0))

    # close them
    inner.end_trace(0.21)
    middle.end_trace(0.22)
    s.end_trace(0.23)
    assert_equal(">>   0 ms [Segment] Custom/test/metric \n  >> 100 ms [Segment] Custom/test/middle \n    >> 200 ms [Segment] Custom/test/inner \n    << 210 ms Custom/test/inner\n  << 220 ms Custom/test/middle\n<< 230 ms Custom/test/metric\n", s.to_debug_str(0))
  end

  def test_called_segments_default
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal([], s.called_segments)
  end

  def test_called_segments_with_segments
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    s.add_called_segment(fake_segment)

    assert_equal([fake_segment], s.called_segments)
  end

  def test_duration
    fake_entry_timestamp = mock('entry timestamp')
    fake_exit_timestamp = mock('exit timestamp')
    fake_result = mock('numeric')
    fake_exit_timestamp.expects(:-).with(fake_entry_timestamp).returns(fake_result)
    fake_result.expects(:to_f).returns(0.5)

    s = NewRelic::TransactionSample::Segment.new(fake_entry_timestamp, 'Custom/test/metric', nil)
    s.end_trace(fake_exit_timestamp)
    assert_equal(0.5, s.duration)
  end

  def test_exclusive_duration_no_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.expects(:duration).returns(0.5)
    assert_equal(0.5, s.exclusive_duration)
  end

  def test_exclusive_duration_with_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    s.expects(:duration).returns(0.5)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:duration).returns(0.1)

    s.add_called_segment(fake_segment)

    assert_equal(0.4, s.exclusive_duration)
  end

  def test_count_segments_default
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(1, s.count_segments)
  end

  def test_count_segments_with_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:count_segments).returns(1)

    s.add_called_segment(fake_segment)

    assert_equal(2, s.count_segments)
    end

  def test_truncate_returns_number_of_elements
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(1, s.truncate(1))
    dup = s.dup
    s.called_segments = [dup]
    assert_equal(2, s.truncate(2))

    s.called_segments = [dup, dup]
    assert_equal(3, s.truncate(3))
  end


  def test_truncate_default
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    assert_equal(1, s.truncate(1))
  end

  def test_truncate_with_a_child
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:truncate).with(1).returns(1)

    s.add_called_segment(fake_segment)

    assert_equal(2, s.truncate(2))
    assert_equal([fake_segment], s.called_segments)

    assert_equal(1, s.truncate(1))
    assert_equal([], s.called_segments)
  end

  def test_truncate_with_multiple_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    fake_segment = mock('segment')
    fake_segment.expects(:truncate).with(2).returns(1)

    other_segment = mock('other segment')
    other_segment.expects(:truncate).with(1).returns(1)

    s.called_segments = [fake_segment, other_segment]
    assert_equal(3, s.truncate(3))
    assert_equal([fake_segment, other_segment], s.called_segments)
  end

  def test_truncate_removes_elements
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    fake_segment = mock('segment')
    fake_segment.expects(:truncate).with(1).returns(1)

    other_segment = mock('other segment')

    s.called_segments = [fake_segment, other_segment]
    assert_equal(2, s.truncate(2))
    assert_equal([fake_segment], s.called_segments)
  end

  def test_key_equals
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    # doing this to hold the reference to the hash
    params = {}
    s.params = params
    assert_equal(params, s.params)

    # should delegate to the same hash we have above
    s[:foo] = 'correct'

    assert_equal('correct', params[:foo])
  end

  def test_key
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.params = {:foo => 'correct'}
    assert_equal('correct', s[:foo])
  end

  def test_params
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    # should have a default value
    assert_equal(nil, s.instance_eval { @params })
    assert_equal({}, s.params)

    # should otherwise take the value from the @params var
    s.instance_eval { @params = {:foo => 'correct'} }
    assert_equal({:foo => 'correct'}, s.params)
  end

  def test_each_segment_default
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    # in the base case it just yields the block to itself
    count = 0
    s.each_segment do |x|
      count += 1
      assert_equal(s, x)
    end
    # should only run once
    assert_equal(1, count)
  end

  def test_each_segment_with_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    fake_segment = mock('segment')
    fake_segment.expects(:parent_segment=).with(s)
    fake_segment.expects(:each_segment).yields(fake_segment)

    s.add_called_segment(fake_segment)

    count = 0
    s.each_segment do |x|
      count += 1
    end

    assert_equal(2, count)
  end

  def test_each_segment_with_nest_tracking
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)

    summary = mock('summary')
    summary.expects(:current_nest_count).twice.returns(0).then.returns(1)
    summary.expects(:current_nest_count=).twice
    s.each_segment_with_nest_tracking do |x|
      summary
    end
  end

  def test_find_segment_default
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    id_to_find = s.segment_id
    # should return itself in the base case
    assert_equal(s, s.find_segment(id_to_find))
  end

  def test_find_segment_not_found
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(nil, s.find_segment(-1))
  end

  def test_find_segment_with_children
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    id_to_find = s.segment_id
    # should return itself in the base case
    assert_equal(s, s.find_segment(id_to_find))
  end

  def test_explain_sql_no_sql
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.params = {:sql => nil}
    assert_equal(nil, s.explain_sql)
  end

  def test_explain_sql_no_connection_config
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.params = {:sql => 'foo', :connection_config => nil}
    assert_equal(nil, s.explain_sql)
  end

  def test_explain_sql_non_select
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.params = {:sql => 'foo', :connection_config => mock('config')}
    assert_equal([], s.explain_sql)
  end

  def test_explain_sql_one_select_no_connection
    # NB this test raises an error in the log, much as it might if a
    # user supplied a config that was not valid. This is generally
    # expected behavior - the get_connection method shouldn't allow
    # errors to percolate up.
    config = mock('config')
    config.stubs(:[]).returns(nil)
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s.params = {:sql => 'SELECT', :connection_config => config}
    assert_equal([], s.explain_sql)
  end

  def test_explain_sql_one_select_with_connection
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    config = mock('config')
    s.params = {:sql => 'SELECT', :connection_config => config}
    connection = mock('connection')
    # two rows, two columns
    connection.expects(:execute).with('EXPLAIN SELECT').returns([["string", "string"], ["string", "string"]])
    NewRelic::TransactionSample.expects(:get_connection).with(config).returns(connection)
    assert_equal([[['string', 'string'], ['string', 'string']]], s.explain_sql)
  end

  # this basically casts the resultset to an array of rows, which are
  # arrays of columns
  def test_process_resultset
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    items = mock('bar')
    row = ["column"]
    items.expects(:respond_to?).with(:each).returns(true)
    items.expects(:each).yields(row)
    assert_equal([["column"]], s.process_resultset(items))
  end

  def test_explain_sql_two_selects_with_connection
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    config = mock('config')
    s.params = {:sql => "SELECT true();\nSELECT false()", :connection_config => config}
    connection = mock('connection')
    # two rows, two columns
    connection.expects(:execute).returns([["string", "string"], ["string", "string"]]).twice
    NewRelic::TransactionSample.expects(:get_connection).with(config).returns(connection).twice
    assert_equal([[['string', 'string'], ['string', 'string']], [['string', 'string'], ['string', 'string']]], s.explain_sql)
  end

  def test_explain_sql_raising_an_error
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    config = mock('config')
    s.params = {:sql => 'SELECT', :connection_config => config}
    connection = mock('connection')
    NewRelic::TransactionSample.expects(:get_connection).with(config).raises(RuntimeError.new("whee"))
    assert_nothing_raised do
      s.explain_sql
    end
  end

  def test_params_equal
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(nil, s.instance_eval { @params })

    params = {:foo => 'correct'}

    s.params = params
    assert_equal(params, s.instance_eval { @params })
  end

  def test_handle_exception_in_explain
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    fake_error = Exception.new
    fake_error.expects(:message).returns('a message')
    NewRelic::Control.instance.log.expects(:error).with('Error getting explain plan: a message')
    # backtrace can be basically any string, just should get logged
    NewRelic::Control.instance.log.expects(:debug).with(instance_of(String))
    s.handle_exception_in_explain do
      raise(fake_error)
    end
  end

  def test_obfuscated_sql
    sql = 'some sql'
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    s[:sql] = sql
    NewRelic::TransactionSample.expects(:obfuscate_sql).with(sql)
    s.obfuscated_sql
  end

  def test_called_segments_equals
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(nil, s.instance_eval { @called_segments })
    s.called_segments = [1, 2, 3]
    assert_equal([1, 2, 3], s.instance_eval { @called_segments })
  end

  def test_parent_segment_equals
    s = NewRelic::TransactionSample::Segment.new(Time.now, 'Custom/test/metric', nil)
    assert_equal(nil, s.instance_eval { @parent_segment })
    fake_segment = mock('segment')
    s.send(:parent_segment=, fake_segment)
    assert_equal(fake_segment, s.parent_segment)
  end
end

