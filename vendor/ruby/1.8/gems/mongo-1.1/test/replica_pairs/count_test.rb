$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: this test should be run only if a replica pair is running.
class ReplicaPairCountTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new({:left => ["localhost", 27017], :right => ["localhost", 27018]}, nil)
    @db = @conn.db('mongo-ruby-test')
    @db.drop_collection("test-pairs")
    @coll = @db.collection("test-pairs")
  end

  def test_correct_count_after_insertion_reconnect
    @coll.insert({:a => 20}, :safe => true)
    assert_equal 1, @coll.count

    # Sleep to allow resync
    sleep(3)

    puts "Please disconnect the current master."
    gets

    rescue_connection_failure do
      @coll.insert({:a => 30}, :safe => true)
    end
    @coll.insert({:a => 40}, :safe => true)
    assert_equal 3, @coll.count, "Second count failed"
  end

end
