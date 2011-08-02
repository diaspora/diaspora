require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper'))
class NewRelic::Agent::Instrumentation::QueueTimeTest < Test::Unit::TestCase
  require 'new_relic/agent/instrumentation/queue_time'
  include NewRelic::Agent::Instrumentation::QueueTime

  def setup
    NewRelic::Agent.instance.stats_engine.clear_stats
  end

  def create_test_start_time(env)
    env[APP_HEADER] = "t=#{convert_to_microseconds(Time.at(1002))}"
  end

  def test_parse_frontend_headers
    middleware_start = Time.at(1002)
    queue_start = Time.at(1001)
    server_start = Time.at(1000)
    Time.stubs(:now).returns(Time.at(1003)) # whee!
    self.expects(:add_end_time_header).with(Time.at(1003), {:env => 'hash'})
    # ordering is important here, unfortunately, the mocks don't
    # support that kind of checking.
    self.expects(:parse_middleware_time_from).with({:env => 'hash'}).returns(middleware_start)
    self.expects(:parse_queue_time_from).with({:env => 'hash'}).returns(queue_start)
    self.expects(:parse_server_time_from).with({:env => 'hash'}).returns(server_start)
    assert_equal(server_start, parse_frontend_headers({:env => 'hash'}), "should return the oldest start time")
  end

  def test_parse_frontend_headers_should_return_earliest_start
    middleware_start = Time.at(1002)
    queue_start = Time.at(1000)
    server_start = Time.at(1001)
    Time.stubs(:now).returns(Time.at(1003)) # whee!
    self.expects(:add_end_time_header).with(Time.at(1003), {:env => 'hash'})
    # ordering is important here, unfortunately, the mocks don't
    # support that kind of checking.
    self.expects(:parse_middleware_time_from).with({:env => 'hash'}).returns(middleware_start)
    self.expects(:parse_queue_time_from).with({:env => 'hash'}).returns(queue_start)
    self.expects(:parse_server_time_from).with({:env => 'hash'}).returns(server_start)
    assert_equal(queue_start, parse_frontend_headers({:env => 'hash'}), "should return the oldest start time")
  end

  def test_all_combined_frontend_headers
    env = {}
    env[MAIN_HEADER] = "t=#{convert_to_microseconds(Time.at(1000))}"
    env[QUEUE_HEADER] = "t=#{convert_to_microseconds(Time.at(1001))}"
    env[MIDDLEWARE_HEADER] = "t=#{convert_to_microseconds(Time.at(1002))}"

    env[APP_HEADER] = "t=#{convert_to_microseconds(Time.at(1003))}"

    assert_calls_metrics('WebFrontend/WebServer/all', 'WebFrontend/QueueTime', 'Middleware/all') do
      assert_equal(Time.at(1002), parse_middleware_time_from(env))
      assert_equal(Time.at(1001), parse_queue_time_from(env))
      assert_equal(Time.at(1000), parse_server_time_from(env))
    end

    check_metric_time('WebFrontend/WebServer/all', 1.0, 0.001)
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
    check_metric_time('Middleware/all', 1.0, 0.001)
  end

  def test_combined_middleware_and_queue
    env = {}
    env[QUEUE_HEADER] = "t=#{convert_to_microseconds(Time.at(1000))}"
    env[MIDDLEWARE_HEADER] = "t=#{convert_to_microseconds(Time.at(1001))}"
    create_test_start_time(env)

    assert_calls_metrics('Middleware/all', 'WebFrontend/QueueTime') do
      parse_middleware_time_from(env)
      assert_equal(Time.at(1000), parse_queue_time_from(env))
    end

    check_metric_time('Middleware/all', 1.0, 0.001)
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  def test_combined_queue_and_server
    env = {}
    env[MAIN_HEADER] = "t=#{convert_to_microseconds(Time.at(1000))}"
    env[QUEUE_HEADER] = "t=#{convert_to_microseconds(Time.at(1001))}"
    create_test_start_time(env)

    assert_calls_metrics('WebFrontend/WebServer/all', 'WebFrontend/QueueTime') do
      assert_equal(Time.at(1001), parse_queue_time_from(env))
      parse_server_time_from(env)
    end

    check_metric_time('WebFrontend/WebServer/all', 1.0, 0.001)
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  def test_combined_middleware_and_server
    env = {}
    env[MAIN_HEADER] = "t=#{convert_to_microseconds(Time.at(1000))}"
    env[MIDDLEWARE_HEADER] = "t=#{convert_to_microseconds(Time.at(1001))}"
    create_test_start_time(env)

    assert_calls_metrics('WebFrontend/WebServer/all', 'Middleware/all') do
      parse_middleware_time_from(env)
      parse_server_time_from(env)
    end

    check_metric_time('WebFrontend/WebServer/all', 1.0, 0.001)
    check_metric_time('Middleware/all', 1.0, 0.001)
  end

  # initial base case, a router and a static content server
  def test_parse_server_time_from_initial
    env = {}
    create_test_start_time(env)
    time1 = convert_to_microseconds(Time.at(1000))
    time2 = convert_to_microseconds(Time.at(1001))
    env['HTTP_X_REQUEST_START'] = "servera t=#{time1}, serverb t=#{time2}"
    assert_calls_metrics('WebFrontend/WebServer/all', 'WebFrontend/WebServer/servera', 'WebFrontend/WebServer/serverb') do
      parse_server_time_from(env)
    end
    check_metric_time('WebFrontend/WebServer/all', 2.0, 0.1)
    check_metric_time('WebFrontend/WebServer/servera', 1.0, 0.1)
    check_metric_time('WebFrontend/WebServer/serverb', 1.0, 0.1)
  end

  # test for backwards compatibility with old header
  def test_parse_server_time_from_with_no_server_name
    env = {'HTTP_X_REQUEST_START' => "t=#{convert_to_microseconds(Time.at(1001))}"}
    create_test_start_time(env)
    assert_calls_metrics('WebFrontend/WebServer/all') do
      parse_server_time_from(env)
    end
    check_metric_time('WebFrontend/WebServer/all', 1.0, 0.1)
  end

  def test_parse_server_time_from_with_bad_header
    env = {'HTTP_X_REQUEST_START' => 't=t=t=t='}
    create_test_start_time(env)
    assert_calls_metrics('WebFrontend/WebServer/all') do
      parse_server_time_from(env)
    end
  end

  def test_parse_server_time_from_with_no_header
    assert_calls_metrics('WebFrontend/WebServer/all') do
      parse_server_time_from({})
    end
  end

  def test_parse_middleware_time
    env = {}
    create_test_start_time(env)
    time1 = convert_to_microseconds(Time.at(1000))
    time2 = convert_to_microseconds(Time.at(1001))

    env['HTTP_X_MIDDLEWARE_START'] = "base t=#{time1}, second t=#{time2}"
    assert_calls_metrics('Middleware/all', 'Middleware/base', 'Middleware/second') do
      parse_middleware_time_from(env)
    end
    check_metric_time('Middleware/all', 2.0, 0.1)
    check_metric_time('Middleware/base', 1.0, 0.1)
    check_metric_time('Middleware/second', 1.0, 0.1)
  end

  def test_parse_queue_time
    env = {}
    create_test_start_time(env)
    time1 = convert_to_microseconds(Time.at(1000))

    env['HTTP_X_QUEUE_START'] = "t=#{time1}"
    assert_calls_metrics('WebFrontend/QueueTime') do
      assert_equal(Time.at(1000), parse_queue_time_from(env))
    end

    check_metric_time('WebFrontend/QueueTime', 2.0, 0.1)
  end

  def test_check_for_alternate_queue_length
    env = {}
    create_test_start_time(env)
    env['HTTP_X_QUEUE_TIME'] = '1000000'
    assert_calls_metrics('WebFrontend/QueueTime') do
      assert_equal(Time.at(1001), parse_queue_time_from(env))
    end

    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  def test_check_for_alternate_queue_length_override
    env = {}
    create_test_start_time(env)
    env['HTTP_X_QUEUE_START'] = 't=1' # obviously incorrect
    env['HTTP_X_QUEUE_TIME'] = '1000000'
    assert_calls_metrics('WebFrontend/QueueTime') do
      assert_equal(Time.at(1001), parse_queue_time_from(env))
    end

    # alternate queue should override normal header
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  def test_check_for_heroku_queue_length
    env = {}
    create_test_start_time(env)
    env['HTTP_X_HEROKU_QUEUE_WAIT_TIME'] = '1000'
    assert_calls_metrics('WebFrontend/QueueTime') do
      assert_equal(Time.at(1001), parse_queue_time_from(env))
    end

    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  def test_check_for_heroku_queue_length_override
    env = {}
    create_test_start_time(env)
    env['HTTP_X_QUEUE_TIME'] = '10000000' # ten MEEELION useconds
    env['HTTP_X_HEROKU_QUEUE_WAIT_TIME'] = '1000'
    assert_calls_metrics('WebFrontend/QueueTime') do
      assert_equal(Time.at(1001), parse_queue_time_from(env))
    end

    # heroku queue should override alternate queue
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.001)
  end

  # each server should be one second, and the total would be 2 seconds
  def test_record_individual_server_stats
    matches = [['foo', Time.at(1000)], ['bar', Time.at(1001)]]
    assert_calls_metrics('WebFrontend/WebServer/foo', 'WebFrontend/WebServer/bar') do
      record_individual_server_stats(Time.at(1002), matches)
    end
    check_metric_time('WebFrontend/WebServer/foo', 1.0, 0.1)
    check_metric_time('WebFrontend/WebServer/bar', 1.0, 0.1)
  end

  def test_record_rollup_server_stat
    assert_calls_metrics('WebFrontend/WebServer/all') do
      record_rollup_server_stat(Time.at(1001), [['a', Time.at(1000)]])
    end
    check_metric_time('WebFrontend/WebServer/all', 1.0, 0.1)
  end

  def test_record_rollup_server_stat_no_data
    assert_calls_metrics('WebFrontend/WebServer/all') do
      record_rollup_server_stat(Time.at(1001), [])
    end
    check_metric_time('WebFrontend/WebServer/all', 0.0, 0.001)
  end

  def test_record_rollup_middleware_stat
    assert_calls_metrics('Middleware/all') do
      record_rollup_middleware_stat(Time.at(1001), [['a', Time.at(1000)]])
    end
    check_metric_time('Middleware/all', 1.0, 0.1)
  end

  def test_record_rollup_middleware_stat_no_data
    assert_calls_metrics('Middleware/all') do
      record_rollup_middleware_stat(Time.at(1001), [])
    end
    check_metric_time('Middleware/all', 0.0, 0.001)
  end

  def test_record_rollup_queue_stat
    assert_calls_metrics('WebFrontend/QueueTime') do
      record_rollup_queue_stat(Time.at(1001), [[nil, Time.at(1000)]])
    end
    check_metric_time('WebFrontend/QueueTime', 1.0, 0.1)
  end

  def test_record_rollup_queue_stat_no_data
    assert_calls_metrics('WebFrontend/QueueTime') do
      record_rollup_queue_stat(Time.at(1001), [])
    end
    check_metric_time('WebFrontend/QueueTime', 0.0, 0.001)
  end


  # check all the combinations to make sure that ordering doesn't
  # affect the return value
  def test_find_oldest_time
    test_arrays = [
                   ['a', Time.at(1000)],
                   ['b', Time.at(1001)],
                   ['c', Time.at(1002)],
                   ['d', Time.at(1000)],
                  ]
    test_arrays = test_arrays.permutation
    test_arrays.each do |test_array|
      assert_equal find_oldest_time(test_array), Time.at(1000), "Should be the oldest time in the array"
    end
  end

  # trivial test but the method doesn't do much
  def test_record_server_time_for
    name = 'foo'
    time = Time.at(1000)
    start_time = Time.at(1001)
    self.expects(:record_time_stat).with('WebFrontend/WebServer/foo', time, start_time)
    record_server_time_for(name, time, start_time)
  end

  def test_record_time_stat
    assert_calls_metrics('WebFrontend/WebServer/foo') do
      record_time_stat('WebFrontend/WebServer/foo', Time.at(1000), Time.at(1001))
    end
    check_metric_time('WebFrontend/WebServer/foo', 1.0, 0.1)
    assert_raises(RuntimeError) do
      record_time_stat('foo', Time.at(1001), Time.at(1000))
    end
  end

  def test_record_time_stat_with_end_after_start
    record_time_stat('WebFrontend/WebServer/foo', 2, 1)
  rescue RuntimeError => e
    assert_equal("should not provide an end time less than start time: 1 is less than 2", e.message)
  end

  def test_convert_to_microseconds
    assert_equal((1_000_000_000), convert_to_microseconds(Time.at(1000)), 'time at 1000 seconds past epoch should be 1,000,000,000 usec')
    assert_equal 1_000_000_000, convert_to_microseconds(1_000_000_000), 'should not mess with a number if passed in'
    assert_raises(TypeError) do
      convert_to_microseconds('whoo yeah buddy')
    end
  end

  def test_convert_from_microseconds
    assert_equal Time.at(1000), convert_from_microseconds(1_000_000_000), 'time at 1,000,000,000 usec should be 1000 seconds after epoch'
    assert_equal Time.at(1000), convert_from_microseconds(Time.at(1000)), 'should not mess with a time passed in'
    assert_raises(TypeError) do
      convert_from_microseconds('10000000000')
    end
  end

  def test_add_end_time_header
    env = {}
    start_time = Time.at(1)
    add_end_time_header(start_time, env)
    assert_equal({'HTTP_X_APPLICATION_START' => "t=#{convert_to_microseconds(Time.at(1))}"}, env, "should add the header to the env hash")
  end

  def test_parse_end_time_base
    env = {}
    env['HTTP_X_APPLICATION_START'] = "t=#{convert_to_microseconds(Time.at(1))}"
    start_time = parse_end_time(env)
    assert_equal(Time.at(1), start_time, "should pull the correct start time from the app header")
  end

  def test_get_matches_from_header
    env = {'A HEADER' => 't=1000000'}
    self.expects(:convert_from_microseconds).with(1000000).returns(Time.at(1))
    matches = get_matches_from_header('A HEADER', env)
    assert_equal [[nil, Time.at(1)]], matches, "should pull the correct time from the string"
  end

  def test_convert_to_name_time_pair
    name = :foo
    time = "1000000"

    pair = convert_to_name_time_pair(name, time)
    assert_equal [:foo, Time.at(1)], pair
  end

  def test_get_matches
    str = "servera t=1000000, serverb t=1000000"
    matches = get_matches(str) # start a fire
    assert_equal [['servera', '1000000'], ['serverb', '1000000']], matches
  end

  def test_matches_with_bad_data
    str = "stephan is a dumb lol"
    matches = get_matches(str)
    assert_equal [], matches

    str = "t=100"
    matches = get_matches(str)
    assert_equal [[nil, '100']], matches

    str = nil
    matches = get_matches(str)
    assert_equal [], matches
  end
  # each server should be one second, and the total would be 2 seconds
  def test_record_individual_middleware_stats
    matches = [['foo', Time.at(1000)], ['bar', Time.at(1001)]]
    assert_calls_metrics('Middleware/foo', 'Middleware/bar') do
      record_individual_middleware_stats(Time.at(1002), matches)
    end
    check_metric_time('Middleware/foo', 1.0, 0.1)
    check_metric_time('Middleware/bar', 1.0, 0.1)
  end
end
