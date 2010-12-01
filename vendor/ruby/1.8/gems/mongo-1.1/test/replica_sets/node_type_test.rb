$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: This test expects a replica set of three nodes, one of which is an arbiter, to be running
# on the local host.
class ReplicaSetNodeTypeTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.multi([['localhost', 27017], ['localhost', 27018], ['localhost', 27019]])
    @db = @conn.db(MONGO_TEST_DB)
    @db.drop_collection("test-sets")
    @coll = @db.collection("test-sets")
  end

  def test_correct_node_types
    p @conn.primary
    p @conn.secondaries
    p @conn.arbiters
    assert_equal 1, @conn.secondaries.length
    assert_equal 1, @conn.arbiters.length

    old_secondary = @conn.secondaries.first
    old_primary   = @conn.primary

    puts "Please disconnect the current primary and reconnect so that it becomes secondary."
    gets

    # Insert something to rescue the connection failure.
    rescue_connection_failure do
      @coll.insert({:a => 30}, :safe => true)
    end

    assert_equal 1, @conn.secondaries.length
    assert_equal 1, @conn.arbiters.length
    assert_equal old_primary, @conn.secondaries.first
    assert_equal old_secondary, @conn.primary
  end

end
