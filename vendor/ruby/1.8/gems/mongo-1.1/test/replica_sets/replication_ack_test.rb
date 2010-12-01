$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: This test expects a replica set of three nodes to be running on local host.
class ReplicaSetAckTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.multi([['localhost', 27017], ['localhost', 27018], ['localhost', 27019]])

    master = [@conn.host, @conn.port]
    @slaves = @conn.nodes - master

    @slave1 = Mongo::Connection.new(@slaves[0][0], @slaves[0][1], :slave_ok => true)
    @slave2 = Mongo::Connection.new(@slaves[1][0], @slaves[1][1], :slave_ok => true)

    @db = @conn.db(MONGO_TEST_DB)
    @db.drop_collection("test-sets")
    @col = @db.collection("test-sets")
  end

  def test_safe_mode_with_w_failure
    assert_raise_error OperationFailure, "timed out waiting for slaves" do
      @col.insert({:foo => 1}, :safe => {:w => 4, :wtimeout => 1, :fsync => true})
    end
    assert_raise_error OperationFailure, "timed out waiting for slaves" do
      @col.update({:foo => 1}, {:foo => 2}, :safe => {:w => 4, :wtimeout => 1, :fsync => true})
    end
    assert_raise_error OperationFailure, "timed out waiting for slaves" do
      @col.remove({:foo => 2}, :safe => {:w => 4, :wtimeout => 1, :fsync => true})
    end
  end

  def test_safe_mode_replication_ack
    @col.insert({:baz => "bar"}, :safe => {:w => 3, :wtimeout => 1000})

    assert @col.insert({:foo => "0" * 10000}, :safe => {:w => 3, :wtimeout => 1000})
    assert_equal 2, @slave1[MONGO_TEST_DB]["test-sets"].count
    assert_equal 2, @slave2[MONGO_TEST_DB]["test-sets"].count


    assert @col.update({:baz => "bar"}, {:baz => "foo"}, :safe => {:w => 3, :wtimeout => 1000})
    assert @slave1[MONGO_TEST_DB]["test-sets"].find_one({:baz => "foo"})
    assert @slave2[MONGO_TEST_DB]["test-sets"].find_one({:baz => "foo"})

    assert @col.remove({}, :safe => {:w => 3, :wtimeout => 1000})
    assert_equal 0, @slave1[MONGO_TEST_DB]["test-sets"].count
    assert_equal 0, @slave2[MONGO_TEST_DB]["test-sets"].count
  end

  def test_last_error_responses
    20.times { @col.insert({:baz => "bar"}) }
    response = @db.get_last_error(:w => 3, :wtimeout => 10000)
    assert response['ok'] == 1
    assert response['lastOp']

    @col.update({}, {:baz => "foo"}, :multi => true)
    response = @db.get_last_error(:w => 3, :wtimeout => 1000)
    assert response['ok'] == 1
    assert response['lastOp']

    @col.remove({})
    response =  @db.get_last_error(:w => 3, :wtimeout => 1000)
    assert response['ok'] == 1
    assert response['n'] == 20
    assert response['lastOp']
  end

end
