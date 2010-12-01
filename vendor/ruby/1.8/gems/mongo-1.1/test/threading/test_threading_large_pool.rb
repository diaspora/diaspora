require 'test/test_helper'

# Essentialy the same as test_threading.rb but with an expanded pool for
# testing multiple connections.
class TestThreadingLargePool < Test::Unit::TestCase

  include Mongo

  @@db = Connection.new('localhost', 27017, :pool_size => 50, :timeout => 60).db(MONGO_TEST_DB)
  @@coll = @@db.collection('thread-test-collection')

  def set_up_safe_data
    @@db.drop_collection('duplicate')
    @@db.drop_collection('unique')
    @duplicate = @@db.collection('duplicate')
    @unique    = @@db.collection('unique')

    @duplicate.insert("test" => "insert")
    @duplicate.insert("test" => "update")
    @unique.insert("test" => "insert")
    @unique.insert("test" => "update")
    @unique.create_index("test", :unique => true)
  end

  def test_safe_update
    set_up_safe_data
    threads = []
    300.times do |i|
      threads[i] = Thread.new do
        if i % 2 == 0
          assert_raise Mongo::OperationFailure do
            @unique.update({"test" => "insert"}, {"$set" => {"test" => "update"}}, :safe => true)
          end
        else
          @duplicate.update({"test" => "insert"}, {"$set" => {"test" => "update"}}, :safe => true)
        end
      end
    end

    300.times do |i|
      threads[i].join
    end
  end

  def test_safe_insert
    set_up_safe_data
    threads = []
    300.times do |i|
      threads[i] = Thread.new do
        if i % 2 == 0
          assert_raise Mongo::OperationFailure do
            @unique.insert({"test" => "insert"}, :safe => true)
          end
        else
          @duplicate.insert({"test" => "insert"}, :safe => true)
        end
      end
    end

    300.times do |i|
      threads[i].join
    end
  end

  def test_threading
    @@coll.drop
    @@coll = @@db.collection('thread-test-collection')

    1000.times do |i|
      @@coll.insert("x" => i)
    end

    threads = []

    10.times do |i|
      threads[i] = Thread.new do
        sum = 0
        @@coll.find().each do |document|
          sum += document["x"]
        end
        assert_equal 499500, sum
      end
    end

    10.times do |i|
      threads[i].join
    end
  end

end
