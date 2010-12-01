require './test/test_helper'
require 'logger'

class CursorTest < Test::Unit::TestCase

  include Mongo

  @@connection = Connection.new(ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
                        ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT)
  @@db   = @@connection.db(MONGO_TEST_DB)
  @@coll = @@db.collection('test')
  @@version = @@connection.server_version

  def setup
    @@coll.remove
    @@coll.insert('a' => 1)     # collection not created until it's used
    @@coll_full_name = "#{MONGO_TEST_DB}.test"
  end

  def test_valid_batch_sizes
    assert_raise ArgumentError do
      @@coll.find({}, :batch_size => 1, :limit => 5)
    end

    assert_raise ArgumentError do
      @@coll.find({}, :batch_size => -1, :limit => 5)
    end

    assert @@coll.find({}, :batch_size => 0, :limit => 5)
  end

  def test_batch_size
    @@coll.remove
    200.times do |n|
      @@coll.insert({:a => n})
    end

    list = @@coll.find({}, :batch_size => 2, :limit => 6).to_a
    assert_equal 6, list.length

    list = @@coll.find({}, :batch_size => 100, :limit => 101).to_a
    assert_equal 101, list.length
  end
end
