##############################################################################
# tc_date.rb
#
# Test case for the DBI::Date class (currently) located in the utils.rb file.
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
      @date     = Date.new
      @time     = Time.now
      @dbi_date = DBI::Date.new
   end

   def test_constructor
      assert_nothing_raised{ DBI::Date.new(2006) }
      assert_nothing_raised{ DBI::Date.new(2006, 1) }
      assert_nothing_raised{ DBI::Date.new(2006, 1, 20) }
      assert_nothing_raised{ DBI::Date.new(Date.new) }
      assert_nothing_raised{ DBI::Date.new(Time.now) }
   end

   def test_year
      assert_respond_to(@dbi_date, :year)
      assert_respond_to(@dbi_date, :year=)
      assert_equal(0, @dbi_date.year)
   end

   def test_month
      assert_respond_to(@dbi_date, :month)
      assert_respond_to(@dbi_date, :month=)
   end

   # An alias for :month, :month=
   def test_mon
      assert_respond_to(@dbi_date, :mon)
      assert_respond_to(@dbi_date, :mon=)
      assert_equal(0, @dbi_date.mon)
   end

   def test_day
      assert_respond_to(@dbi_date, :day)
      assert_respond_to(@dbi_date, :day=)
      assert_equal(0, @dbi_date.day)
   end

   # An alias for :day, :day=
   def test_mday
      assert_respond_to(@dbi_date, :mday)
      assert_respond_to(@dbi_date, :mday=)
   end

   def test_to_time
      assert_respond_to(@dbi_date, :to_time)
      assert_equal(@time, DBI::Date.new(@time).to_time)
      assert_equal(@time.object_id, DBI::Date.new(@time).to_time.object_id)
   end

   def test_to_date
      assert_respond_to(@dbi_date, :to_date)
      assert_equal(@date, DBI::Date.new(@date).to_date)
      assert_equal(@date.object_id, DBI::Date.new(@date).to_date.object_id)
   end

   # We test .to_s because it has an explicit implementation
   def test_to_s
      assert_respond_to(@dbi_date, :to_s)
      assert_nothing_raised{ @dbi_date.to_s }
      assert_kind_of(String, @dbi_date.to_s)
      assert_equal("0000-00-00", @dbi_date.to_s)
   end

   def teardown
      @date = nil
      @time = nil
      @dbi_date = nil
   end
end
