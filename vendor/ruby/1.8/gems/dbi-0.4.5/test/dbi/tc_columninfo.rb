############################################################
# tc_columninfo.rb
#
# Test case for the DBI::ColumnInfo class.
############################################################
$LOAD_PATH.unshift(Dir.pwd)
$LOAD_PATH.unshift(File.dirname(Dir.pwd))
$LOAD_PATH.unshift("../../lib")
$LOAD_PATH.unshift("../../lib/dbi")
$LOAD_PATH.unshift("lib")

require "dbi/columninfo"
require "test/unit"

class TC_DBI_ColumnInfo < Test::Unit::TestCase
   def setup
      @colinfo = DBI::ColumnInfo.new(
         "name"      => "test",
         "sql_type"  => "numeric",
         "type_name" => "test_type_name",
         "precision" => 2,
         "scale"     => 2,
         "default"   => 100.00,
         "nullable"  => false,
         "indexed"   => true,
         "primary"   => true,
         "unique"    => false
      )
      @keys = %w/name sql_type type_name precision scale default nullable
         indexed primary unique
      /
   end
   
   def test_constructor
      assert_nothing_raised{ DBI::ColumnInfo.new }

      assert_nothing_raised do
          DBI::ColumnInfo.new({"foo" => "bar", "baz" => "quux"})
          DBI::ColumnInfo.new({:foo => "bar", :baz => "quux"})
      end

      assert_raises(TypeError) do
          DBI::ColumnInfo.new({"foo" => "bar", :foo => "quux"})
      end
   end

   def test_accessors
       assert_nothing_raised do
           @keys.each do |x|
               assert_equal(@colinfo[x], @colinfo[x.to_sym])
               assert_equal(@colinfo.send(x.to_sym), @colinfo[x.to_sym])
               @colinfo[x] = "poop"
               assert_equal("poop", @colinfo[x])
               assert_equal("poop", @colinfo[x.to_sym])
           end
       end
   end

   def test_precision_basic
      assert_respond_to(@colinfo, :size)
      assert_respond_to(@colinfo, :size=)
      assert_respond_to(@colinfo, :length)
      assert_respond_to(@colinfo, :length=)
   end

   def test_scale_basic
      assert_respond_to(@colinfo, :decimal_digits)
      assert_respond_to(@colinfo, :decimal_digits=)
   end

   def test_default_value_basic
      assert_respond_to(@colinfo, :default_value)
      assert_respond_to(@colinfo, :default_value=)
   end

   def test_unique_basic
      assert_respond_to(@colinfo, :is_unique)
   end

   def test_keys
      assert_respond_to(@colinfo, :keys)
      assert_equal(@keys.sort, @colinfo.keys.collect { |x| x.to_s }.sort)
   end
   
   def test_respond_to_hash_methods
      assert_respond_to(@colinfo, :each)
      assert_respond_to(@colinfo, :empty?)
      assert_respond_to(@colinfo, :has_key?)
   end

   def teardown
      @colinfo = nil
   end
end
