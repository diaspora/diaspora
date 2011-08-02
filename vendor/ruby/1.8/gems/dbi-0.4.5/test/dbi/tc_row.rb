######################################################################
# tc_row.rb
#
# Test case for the DBI::Row class. 
######################################################################
$LOAD_PATH.unshift(Dir.pwd)
$LOAD_PATH.unshift(File.dirname(Dir.pwd))
$LOAD_PATH.unshift("../../lib")
$LOAD_PATH.unshift("../../lib/dbi")
$LOAD_PATH.unshift("lib")

require 'test/unit'
require 'dbi'

class TC_DBI_Row < Test::Unit::TestCase
   def setup
      @data = %w/Daniel Berger 36/
      @cols = %w/first last age/
      @coltypes = [DBI::Type::Varchar, DBI::Type::Varchar, DBI::Type::Integer]
      @row  = DBI::Row.new(@cols, @coltypes, @data.clone)
      @row_noconv = DBI::Row.new(@cols, @coltypes, @data.clone, false) 
   end

   def teardown
      @data = nil
      @cols = nil
      @row  = nil
   end

   def test_row_multiassign # this should only be an issue in 1.8.7 and up, if at all.
       first, last, age = @row
       assert_equal("Daniel", first)
       assert_equal("Berger", last)
       assert_equal(36, age)
   end

   def test_row_noconv
       assert_nothing_raised do
           assert_equal(
               [
                   'Daniel',
                   'Berger',
                   36
               ], @row
           )
           assert_equal(@data, @row_noconv)
       end
   end
   
   # Ensure that constructor only allows Integers or Arrays (or nil)
   def test_row_constructor
      assert_nothing_raised{ DBI::Row.new(@cols, @coltypes) }
      assert_nothing_raised{ DBI::Row.new(@cols, @coltypes, 1) }
      assert_nothing_raised{ DBI::Row.new(@cols, @coltypes, nil) }
      assert_nothing_raised{ DBI::Row.new(@cols, @coltypes, [1,2,3])}
      assert_raises(ArgumentError){ DBI::Row.new }
      assert_raises(ArgumentError){ DBI::Row.new(@cols) }
      assert_raises(TypeError){ DBI::Row.new(@cols, @coltypes, {}) }
   end

   # Test added to ensure that Row#at is equivalent to Row#by_index.  When the
   # latter method is (hopefully) removed, this test can be removed as well.
   def test_at
      assert_respond_to(@row, :at)
      assert_equal(@data[0].to_s, @row.at(0).to_s)
      assert_equal(@data[1].to_s, @row.at(1).to_s)
      assert_equal(@data[2].to_s, @row.at(2).to_s)
      assert_equal(@data[99].to_s, @row.at(99).to_s)
   end
   
   # Should respond to Array and Enumerable methods
   def test_row_delegate
      assert_respond_to(@row, :length)
      assert_respond_to(@row, :each)
      assert_respond_to(@row, :grep)
   end
   
   def test_row_length
      assert_equal(3, @row.length)
      assert_equal(3, DBI::Row.new(@cols, @coltypes).length)
   end

   def test_row_data_by_index
      assert_equal(@data[0], @row.by_index(0))
      assert_equal(@data[1], @row.by_index(1))
      assert_equal(@data[2], @row.by_index(2).to_s)
      assert_nil(@row.by_index(3))
   end
   
   def test_row_data_by_field
      assert_equal @data[0], @row.by_field('first')
      assert_equal @data[1], @row.by_field('last')
      assert_equal @data[2], @row.by_field('age').to_s
      assert_equal nil, @row.by_field('unknown')
   end
   
   def test_row_set_values
      assert_respond_to(@row, :set_values)
      assert_nothing_raised{ @row.set_values(["John", "Doe", 23]) }
      assert_equal("John", @row.by_index(0))
      assert_equal("Doe", @row.by_index(1))
      assert_equal(23, @row.by_index(2))
   end
   
   def test_row_to_h
      assert_respond_to(@row, :to_h)
      assert_nothing_raised{ @row.to_h }
      assert_kind_of(Hash, @row.to_h)
      assert_equal({"first"=>"Daniel", "last"=>"Berger", "age"=>36}, @row.to_h)
   end
   
   def test_row_column_names
      assert_respond_to(@row, :column_names)
      assert_nothing_raised{ @row.column_names }
      assert_kind_of(Array, @row.column_names)
      assert_equal(["first", "last", "age"], @row.column_names)
   end

   # An alias for column_names
   def test_row_field_names
      assert_respond_to(@row, :column_names)
      assert_nothing_raised{ @row.column_names }
      assert_kind_of(Array, @row.column_names)
      assert_equal(["first", "last", "age"], @row.column_names)
   end
   
   def test_indexing_numeric
      assert_equal(@data[0], @row[0])   
      assert_equal(@data[1], @row[1])  
      assert_equal(@data[2], @row[2].to_s)      
   end
   
   def test_indexing_string_or_symbol
      assert_equal(@data[0], @row['first'])
      assert_equal(@data[0], @row[:first])
      assert_equal(@data[1], @row['last'])
      assert_equal(@data[2], @row['age'].to_s)
      assert_equal(nil, @row['unknown'])
   end
   
   def test_indexing_regexp
      assert_equal(["Daniel"], @row[/first/])
      assert_equal(["Berger"], @row[/last/])
      assert_equal([36], @row[/age/])
      assert_equal(["Daniel", "Berger"], @row[/first|last/])
      assert_equal([], @row[/bogus/])
   end

   def test_indexing_array
      assert_equal(["Daniel"], @row[[0]])
      assert_equal(["Daniel"], @row[["first"]])
      assert_equal(["Berger"], @row[[1]])
      assert_equal([36], @row[[2]])
      assert_equal([nil], @row[[3]])
      assert_equal(["Daniel", 36], @row[[0,2]])
      assert_equal(["Daniel", 36], @row[[0,:age]])
   end

   def test_indexing_range
      assert_equal(["Daniel","Berger"], @row[0..1])
      assert_equal(["Berger",36], @row[1..2])
      assert_equal(["Berger",36], @row[1..99])
      assert_equal(nil, @row[90..100])
   end

   # The two argument reference should behave like the second form of Array#[]
   def test_indexing_two_args
      assert_equal([], @row[0,0])
      assert_equal(["Daniel"], @row[0,1])
      assert_equal(["Daniel", "Berger"], @row[0,2])
      assert_equal(["Daniel", "Berger", 36], @row[0,3])
      assert_equal(["Daniel", "Berger", 36], @row[0,99])
   end

   def test_indexing_multiple_args
      assert_equal(["Berger", 36, "Daniel"], @row[:last, :age, :first])
      assert_equal(["Berger", 36, "Daniel"], @row[1, :age, :first])
      assert_equal(["Berger", 36, "Daniel"], @row[1, 2, :first])
      assert_equal(["Berger", 36, "Daniel"], @row[1, 2, 0])
      assert_equal(["Berger", 36, "Daniel", nil], @row[1, 2, 0, 9])
      assert_equal(["Berger", 36, "Daniel", nil], @row[1, 2, 0, :bogus])
   end

   def test_indexing_assignment
      assert_nothing_raised{ @row[0] = "kirk" }
      assert_equal("kirk", @row[0])

      assert_nothing_raised{ @row[:age] = 29 }
      assert_equal(29, @row[:age])

      assert_nothing_raised{ @row[1,2] = "francis" }
      assert_equal("francis", @row[:last])
      assert_nil(@row[:age])
   end

   def test_clone_with
      another_row = @row.clone_with(["Jane", "Smith", 33])
      assert_kind_of(DBI::Row, another_row)
      assert_equal "Jane", another_row.by_index(0)
      assert_equal "Smith", another_row.by_index(1)
      assert_equal 33, another_row.by_index(2)
      assert(@row != another_row)
   end

   def test_iteration
      expect = @data.clone
      @row.each { |value|
         assert_equal(expect.shift, value.to_s)
      }
      assert_equal([], expect)
      @row.collect { |value| "Field=#{value}" }
   end

   def test_row_each_with_name
      assert_respond_to(@row, :each_with_name)
      assert_nothing_raised{ @row.each_with_name{ } }

      @row.each_with_name{ |value, column|
         assert(@cols.include?(column))
         assert(@data.include?(value.to_s))
      }
   end

   def test_to_a
      assert_respond_to(@row, :to_a)
      assert_equal(@data, DBI::Row.new(@cols, @coltypes, @data).to_a.collect { |x| x.to_s })
   end

   def test_dup_clone
      dupped = nil
      cloned = nil

      assert_nothing_raised{ dupped = @row.dup }
      assert_nothing_raised{ cloned = @row.clone }
      assert_nothing_raised{ @row.set_values(["Bill", "Jones", 16])}

      assert_equal(@data, dupped.to_a.collect { |x| x.to_s })
      assert_equal(@data, cloned.to_a.collect { |x| x.to_s })

      assert(dupped.object_id != @row.object_id)
      assert(cloned.object_id != @row.object_id)
   end

   def test_dup_ruby18
      res = []
      r = DBI::Row.new(["col1","col2"],[nil,nil])

      [["one",1],["two",2],["three",3]].each do |x,y|
         r["col1"] = x
         r["col2"] = y
         res << r.dup
      end

      assert_equal res, [["one", 1], ["two", 2], ["three", 3]]
   end
end
