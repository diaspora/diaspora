require './test/test_helper'

class CursorTest < Test::Unit::TestCase
  context "Cursor options" do
    setup do
      @logger     = mock()
      @logger.stubs(:debug)
      @connection = stub(:class => Connection, :logger => @logger)
      @db         = stub(:name => "testing", :slave_ok? => false, :connection => @connection)
      @collection = stub(:db => @db, :name => "items")
      @cursor     = Cursor.new(@collection)
    end

    should "set timeout" do
      assert_equal true, @cursor.timeout
    end

    should "set selector" do
      assert @cursor.selector == {}

      @cursor = Cursor.new(@collection, :selector => {:name => "Jones"})
      assert @cursor.selector == {:name => "Jones"}
    end

    should "set fields" do
      assert_nil @cursor.fields

      @cursor = Cursor.new(@collection, :fields => [:name, :date])
      assert @cursor.fields == {:name => 1, :date => 1}
    end

    should "set mix fields 0 and 1" do
      assert_nil @cursor.fields

      @cursor = Cursor.new(@collection, :fields => {:name => 1, :date => 0})
      assert @cursor.fields == {:name => 1, :date => 0}
    end

    should "set limit" do
      assert_equal 0, @cursor.limit

      @cursor = Cursor.new(@collection, :limit => 10)
      assert_equal 10, @cursor.limit
    end


    should "set skip" do
      assert_equal 0, @cursor.skip

      @cursor = Cursor.new(@collection, :skip => 5)
      assert_equal 5, @cursor.skip
    end

    should "set sort order" do
      assert_nil @cursor.order

      @cursor = Cursor.new(@collection, :order => "last_name")
      assert_equal "last_name", @cursor.order
    end

    should "set hint" do
      assert_nil @cursor.hint

      @cursor = Cursor.new(@collection, :hint => "name")
      assert_equal "name", @cursor.hint
    end

    should "cache full collection name" do
      assert_equal "testing.items", @cursor.full_collection_name
    end
  end

  context "Query fields" do
    setup do
      @connection = stub(:class => Collection, :logger => @logger)
      @db = stub(:slave_ok? => true, :name => "testing", :connection => @connection)
      @collection = stub(:db => @db, :name => "items")
    end

    should "when an array should return a hash with each key" do
      @cursor = Cursor.new(@collection, :fields => [:name, :age])
      result  = @cursor.fields
      assert_equal result.keys.sort{|a,b| a.to_s <=> b.to_s}, [:age, :name].sort{|a,b| a.to_s <=> b.to_s}
      assert result.values.all? {|v| v == 1}
    end

    should "when a string, return a hash with just the key" do
      @cursor = Cursor.new(@collection, :fields => "name")
      result  = @cursor.fields
      assert_equal result.keys.sort, ["name"]
      assert result.values.all? {|v| v == 1}
    end

    should "return nil when neither hash nor string nor symbol" do
      @cursor = Cursor.new(@collection, :fields => 1234567)
      assert_nil @cursor.fields
    end
  end
end
