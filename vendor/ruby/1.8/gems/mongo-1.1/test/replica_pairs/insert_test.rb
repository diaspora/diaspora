$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: this test should be run only if a replica pair is running.
class ReplicaPairInsertTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new({:left => ["localhost", 27017], :right => ["localhost", 27018]}, nil)
    @db = @conn.db('mongo-ruby-test')
    @db.drop_collection("test-pairs")
    @coll = @db.collection("test-pairs")
  end

  def test_insert
    @coll.save({:a => 20}, :safe => true)
    puts "Please disconnect the current master."
    gets

    rescue_connection_failure do
      @coll.save({:a => 30}, :safe => true)
    end

    @coll.save({:a => 40}, :safe => true)
    @coll.save({:a => 50}, :safe => true)
    @coll.save({:a => 60}, :safe => true)
    @coll.save({:a => 70}, :safe => true)

    puts "Please reconnect the old master to make sure that the new master " +
         "has synced with the previous master. Note: this may have happened already."
    gets
    results = []

    rescue_connection_failure do
      @coll.find.each {|r| results << r}
      [20, 30, 40, 50, 60, 70].each do |a|
        assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a}"
      end
    end

    @coll.save({:a => 80}, :safe => true)
    @coll.find.each {|r| results << r}
    [20, 30, 40, 50, 60, 70, 80].each do |a|
      assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a} on second find"
    end
  end

end
