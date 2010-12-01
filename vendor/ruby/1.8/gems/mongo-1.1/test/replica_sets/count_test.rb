$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: This test expects a replica set of three nodes to be running
# on the local host.
class ReplicaSetCountTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.multi([['localhost', 27017], ['localhost', 27018], ['localhost', 27019]])
    @db = @conn.db(MONGO_TEST_DB)
    @db.drop_collection("test-sets")
    @coll = @db.collection("test-sets")
  end

  def test_correct_count_after_insertion_reconnect
    @coll.insert({:a => 20})#, :safe => {:w => 3, :wtimeout => 10000})
    assert_equal 1, @coll.count

    puts "Please disconnect the current master."
    gets

    rescue_connection_failure do
      @coll.insert({:a => 30}, :safe => true)
    end

    @coll.insert({:a => 40}, :safe => true)
    assert_equal 3, @coll.count, "Second count failed"
  end

end
