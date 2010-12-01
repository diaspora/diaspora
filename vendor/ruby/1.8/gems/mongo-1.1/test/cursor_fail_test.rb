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

  def test_refill_via_get_more
    assert_equal 1, @@coll.count
    1000.times { |i|
      assert_equal 1 + i, @@coll.count
      @@coll.insert('a' => i)
    }

    assert_equal 1001, @@coll.count
    count = 0
    @@coll.find.each { |obj|
      count += obj['a']
    }
    assert_equal 1001, @@coll.count

    # do the same thing again for debugging
    assert_equal 1001, @@coll.count
    count2 = 0
    @@coll.find.each { |obj|
      count2 += obj['a']
    }
    assert_equal 1001, @@coll.count

    assert_equal count, count2
    assert_equal 499501, count
  end

  def test_refill_via_get_more_alt_coll
    coll = @@db.collection('test-alt-coll')
    coll.remove
    coll.insert('a' => 1)     # collection not created until it's used
    assert_equal 1, coll.count

    1000.times { |i|
      assert_equal 1 + i, coll.count
      coll.insert('a' => i)
    }

    assert_equal 1001, coll.count
    count = 0
    coll.find.each { |obj|
      count += obj['a']
    }
    assert_equal 1001, coll.count

    # do the same thing again for debugging
    assert_equal 1001, coll.count
    count2 = 0
    coll.find.each { |obj|
      count2 += obj['a']
    }
    assert_equal 1001, coll.count

    assert_equal count, count2
    assert_equal 499501, count
  end

end
