##############################################################################
# tc_time.rb
#
# Test case for the DBI::Time class (currently) located in the utils.rb file.
##############################################################################
$LOAD_PATH.unshift(Dir.pwd)
$LOAD_PATH.unshift(File.dirname(Dir.pwd))
$LOAD_PATH.unshift("../../lib")
$LOAD_PATH.unshift("../../lib/dbi")
$LOAD_PATH.unshift("lib")

require 'dbi'
require 'test/unit'

Deprecate.set_action(proc { })

class TC_DBI_Time < Test::Unit::TestCase
   def setup
      @time     = Time.new
      @dbi_time = DBI::Time.new
   end

   def test_constructor
      assert_nothing_raised{ DBI::Time.new(9) }
      assert_nothing_raised{ DBI::Time.new(9, 41) }
      assert_nothing_raised{ DBI::Time.new(9, 41, 20) }
      assert_nothing_raised{ DBI::Time.new(Date.new) }
      assert_nothing_raised{ DBI::Time.new(Time.now) }
   end

   def test_hour
      assert_respond_to(@dbi_time, :hour)
      assert_respond_to(@dbi_time, :hour=)
      assert_equal(0, @dbi_time.hour)
   end

   def test_minute
      assert_respond_to(@dbi_time, :minute)
      assert_respond_to(@dbi_time, :minute=)
      assert_equal(0, @dbi_time.minute)
   end

   # Alias for minute
   def test_min
      assert_respond_to(@dbi_time, :min)
      assert_respond_to(@dbi_time, :min=)
      assert_equal(0, @dbi_time.min)
   end

   def test_second
      assert_respond_to(@dbi_time, :second)
      assert_respond_to(@dbi_time, :second=)
      assert_equal(0, @dbi_time.second)
   end

   def test_sec
      assert_respond_to(@dbi_time, :sec)
      assert_respond_to(@dbi_time, :sec=)
      assert_equal(0, @dbi_time.sec)
   end

   def test_to_time
      assert_respond_to(@dbi_time, :to_time)
      assert_equal(@time, DBI::Time.new(@time).to_time)
      #assert_equal(@time.object_id, DBI::Time.new(@time).object_id) # Fails ??
   end

   def test_to_s
      assert_respond_to(@dbi_time, :to_s)
      assert_equal("00:00:00", @dbi_time.to_s)
   end

   def teardown
      @time     = nil
      @dbi_time = nil
   end
end
