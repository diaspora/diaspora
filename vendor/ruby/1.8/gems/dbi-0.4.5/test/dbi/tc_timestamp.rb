##############################################################################
# tc_timestamp.rb
#
# Test case for the DBI::Timestamp class (currently) located in the
# utils.rb file.
##############################################################################
$LOAD_PATH.unshift(Dir.pwd)
$LOAD_PATH.unshift(File.dirname(Dir.pwd))
$LOAD_PATH.unshift("../../lib")
$LOAD_PATH.unshift("../../lib/dbi")
$LOAD_PATH.unshift("lib")

require 'date'
require 'dbi'
require 'test/unit'

Deprecate.set_action(proc { })

class TC_DBI_Date < Test::Unit::TestCase
   def setup
      @date   = Date.new
      @time   = Time.now
      @dbi_ts = DBI::Timestamp.new(2006, 1, 31, 10, 23, 22, 45)
   end

   def test_constructor
      assert_nothing_raised{ DBI::Timestamp.new }
      assert_nothing_raised{ DBI::Timestamp.new(2006) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1, 31) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1, 31, 10) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1, 31, 10, 23) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1, 31, 10, 23, 22) }
      assert_nothing_raised{ DBI::Timestamp.new(2006, 1, 31, 10, 23, 22, 45) }
   end

   def test_to_date
      assert_respond_to(@dbi_ts, :to_date)
      assert_kind_of(Date, @dbi_ts.to_date)
   end

   def test_to_time
      assert_respond_to(@dbi_ts, :to_time)
      assert_kind_of(Time, @dbi_ts.to_time)
   end

   def test_to_s
      assert_respond_to(@dbi_ts, :to_s)
      assert_equal("2006-01-31 10:23:22.000000045", @dbi_ts.to_s)
      assert_equal("2008-03-08 10:39:01.0045",
                   DBI::Timestamp.new(2008, 3, 8, 10, 39, 1, 4500000).to_s)
      assert_equal("2008-03-08 10:39:01.0",
                   DBI::Timestamp.new(2008, 3, 8, 10, 39, 1, 0).to_s)
      assert_equal("2008-03-08 10:39:01",
                   DBI::Timestamp.new(2008, 3, 8, 10, 39, 1, nil).to_s)
      assert_equal("0000-00-00 00:00:00", DBI::Timestamp.new.to_s)
   end

   def test_equality
      assert_equal(true, @dbi_ts == DBI::Timestamp.new(2006,1,31,10,23,22,45))
      assert_equal(false, @dbi_ts == DBI::Timestamp.new(2006,1,31,10,23,22,46))
      assert_equal(false, @dbi_ts == nil)
      assert_equal(false, @dbi_ts == 1)
      assert_equal(false, @dbi_ts == "hello")
   end

   def test_fraction
      assert_respond_to(@dbi_ts, :fraction)
      assert_respond_to(@dbi_ts, :fraction=)
      assert_equal(45, @dbi_ts.fraction)
   end

   def test_second
      assert_respond_to(@dbi_ts, :second)
      assert_respond_to(@dbi_ts, :second=)
      assert_equal(22, @dbi_ts.second)
   end

   # Alias for second
   def test_sec
      assert_respond_to(@dbi_ts, :sec)
      assert_respond_to(@dbi_ts, :sec=)
      assert_equal(22, @dbi_ts.sec)
   end

   def test_minute
      assert_respond_to(@dbi_ts, :minute)
      assert_respond_to(@dbi_ts, :minute=)
      assert_equal(23, @dbi_ts.minute)
   end

   # Alias for minute
   def test_min
      assert_respond_to(@dbi_ts, :min)
      assert_respond_to(@dbi_ts, :min=)
      assert_equal(23, @dbi_ts.min)
   end

   def test_hour
      assert_respond_to(@dbi_ts, :hour)
      assert_respond_to(@dbi_ts, :hour=)
      assert_equal(10, @dbi_ts.hour)
   end

   def test_day
      assert_respond_to(@dbi_ts, :day)
      assert_respond_to(@dbi_ts, :day=)
      assert_equal(31, @dbi_ts.day)
   end

   # Alias for day
   def test_mday
      assert_respond_to(@dbi_ts, :mday)
      assert_respond_to(@dbi_ts, :mday=)
      assert_equal(31, @dbi_ts.mday)
   end

   def test_month
      assert_respond_to(@dbi_ts, :month)
      assert_respond_to(@dbi_ts, :month=)
      assert_equal(1, @dbi_ts.month)
   end

   # Alias for month
   def test_mon
      assert_respond_to(@dbi_ts, :mon)
      assert_respond_to(@dbi_ts, :mon=)
      assert_equal(1, @dbi_ts.mon)
   end

   def test_year
      assert_respond_to(@dbi_ts, :year)
      assert_respond_to(@dbi_ts, :year=)
      assert_equal(2006, @dbi_ts.year)
   end

   def teardown
      @date = nil
      @time = nil
      @dbi_ts = nil
   end
end
