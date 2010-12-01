$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: this test should be run only if a replica pair is running.
class ReplicaPairPooledInsertTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new({:left => ["localhost", 27017], :right => ["localhost", 27018]}, nil, :pool_size => 10, :timeout => 5)
    @db = @conn.db('mongo-ruby-test')
    @db.drop_collection("test-pairs")
    @coll = @db.collection("test-pairs")
  end

  def test_insert
    expected_results = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    @coll.save({:a => -1}, :safe => true)
    puts "Please disconnect the current master."
    gets

    threads = []
    10.times do |i|
      threads[i] = Thread.new do
        rescue_connection_failure do
          @coll.save({:a => i}, :safe => true)
        end
      end
    end

    puts "Please reconnect the old master to make sure that the new master " +
         "has synced with the previous master. Note: this may have happened already." +
         "Note also that when connection with multiple threads, you may need to wait a few seconds" +
         "after restarting the old master so that all the data has had a chance to sync." +
         "This is a case of eventual consistency."
    gets
    results = []

    rescue_connection_failure do
      @coll.find.each {|r| results << r}
      expected_results.each do |a|
        assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a}"
      end
    end

    @coll.save({:a => 10}, :safe => true)
    @coll.find.each {|r| results << r}
    (expected_results + [10]).each do |a|
      assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a} on second find"
    end
  end

end
