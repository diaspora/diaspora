require File.expand_path(File.join(File.dirname(__FILE__),'..','..', 'test_helper'))


class NewRelic::Agent::StatsEngineTest < Test::Unit::TestCase
  def setup
    NewRelic::Agent.manual_start
    @engine = NewRelic::Agent::StatsEngine.new
  rescue => e
    puts e
    puts e.backtrace.join("\n")
  end
  def teardown
    @engine.harvest_timeslice_data({},{})
    super
  end

  def test_scope
    @engine.push_scope "scope1"
    assert @engine.peek_scope.name == "scope1"

    expected = @engine.push_scope "scope2"
    @engine.pop_scope expected, 0

    scoped = @engine.get_stats "a"
    scoped.trace_call 3

    assert scoped.total_call_time == 3
    unscoped = @engine.get_stats "a"

    assert scoped == @engine.get_stats("a")
    assert unscoped.total_call_time == 3
  end

  def test_scope__overlap
    NewRelic::Agent.instance.stubs(:stats_engine).returns(@engine)

    @engine.scope_name = 'orlando'
    self.class.trace_execution_scoped('disney', :deduct_call_time_from_parent => false) { sleep 0.1 }
    orlando_disney = @engine.get_stats 'disney'

    @engine.scope_name = 'anaheim'
    self.class.trace_execution_scoped('disney', :deduct_call_time_from_parent => false) { sleep 0.1 }
    anaheim_disney = @engine.get_stats 'disney'

    disney = @engine.get_stats_no_scope "disney"

    assert_not_same orlando_disney, anaheim_disney
    assert_not_equal orlando_disney, anaheim_disney
    assert_equal 1, orlando_disney.call_count
    assert_equal 1, anaheim_disney.call_count
    assert_same disney, orlando_disney.unscoped_stats
    assert_same disney, anaheim_disney.unscoped_stats
    assert_equal 2, disney.call_count
    assert_equal disney.total_call_time, orlando_disney.total_call_time + anaheim_disney.total_call_time

  end

  def test_simplethrowcase(depth=0)

    fail "doh" if depth == 10

    scope = @engine.push_scope "scope#{depth}"

    begin
      test_simplethrowcase(depth+1)
    rescue StandardError => e
      if (depth != 0)
        raise e
      end
    ensure
      @engine.pop_scope scope, 0
    end

    if depth == 0
      assert @engine.peek_scope.nil?
    end
  end


  def test_scope_failure
    scope1 = @engine.push_scope "scope1"
    @engine.push_scope "scope2"

    begin
      @engine.pop_scope scope1
      fail "Didn't throw when scope push/pop mismatched"
    rescue
      # success
    end
  end

  def test_children_time
    t1 = Time.now

    expected1 = @engine.push_scope "a"
    sleep 0.001
    t2 = Time.now

    expected2 = @engine.push_scope "b"
    sleep 0.002
    t3 = Time.now

    expected = @engine.push_scope "c"
    sleep 0.003
    scope = @engine.pop_scope expected, Time.now - t3

    t4 = Time.now

    check_time_approximate 0, scope.children_time
    check_time_approximate 0.003, @engine.peek_scope.children_time

    sleep 0.001
    t5 = Time.now

    expected = @engine.push_scope "d"
    sleep 0.002
    scope = @engine.pop_scope expected, Time.now - t5

    t6 = Time.now

    check_time_approximate 0, scope.children_time

    scope = @engine.pop_scope expected2, Time.now - t2
    assert_equal scope.name, 'b'

    check_time_approximate (t4 - t3) + (t6 - t5), scope.children_time

    scope = @engine.pop_scope expected1, Time.now - t1
    assert_equal scope.name, 'a'

    check_time_approximate (t6 - t2), scope.children_time
  end

  def test_simple_start_transaction
    assert @engine.peek_scope.nil?
    scope = @engine.push_scope "scope"
    @engine.start_transaction
    assert !@engine.peek_scope.nil?
    @engine.pop_scope scope, 0.01
    assert @engine.peek_scope.nil?
    @engine.end_transaction
    assert @engine.peek_scope.nil?
  end


  # test for when the scope stack contains an element only used for tts and not metrics
  def test_simple_tt_only_scope
    scope1 = @engine.push_scope "a", 0, true
    scope2 = @engine.push_scope "b", 10, false
    scope3 = @engine.push_scope "c", 20, true

    @engine.pop_scope scope3, 10
    @engine.pop_scope scope2, 10
    @engine.pop_scope scope1, 10

    assert_equal 0, scope3.children_time
    assert_equal 10, scope2.children_time
    assert_equal 10, scope1.children_time
  end

  def test_double_tt_only_scope
    scope1 = @engine.push_scope "a", 0, true
    scope2 = @engine.push_scope "b", 10, false
    scope3 = @engine.push_scope "c", 20, false
    scope4 = @engine.push_scope "d", 30, true

    @engine.pop_scope scope4, 10
    @engine.pop_scope scope3, 10
    @engine.pop_scope scope2, 10
    @engine.pop_scope scope1, 10

    assert_equal 0, scope4.children_time
    assert_equal 10, scope3.children_time
    assert_equal 10, scope2.children_time
    assert_equal 10, scope1.children_time
  end


  private
  def check_time_approximate(expected, actual)
    assert((expected - actual).abs < 0.1, "Expected between #{expected - 0.1} and #{expected + 0.1}, got #{actual}")
  end

end

