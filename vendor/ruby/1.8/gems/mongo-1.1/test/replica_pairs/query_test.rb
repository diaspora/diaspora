$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: this test should be run only if a replica pair is running.
class ReplicaPairQueryTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new({:left => ["localhost", 27017], :right => ["localhost", 27018]}, nil)
    @db = @conn.db('mongo-ruby-test')
    @db.drop_collection("test-pairs")
    @coll = @db.collection("test-pairs")
  end

  def test_query
    @coll.save({:a => 20})
    @coll.save({:a => 30})
    @coll.save({:a => 40})
    results = []
    @coll.find.each {|r| results << r}
    [20, 30, 40].each do |a|
      assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a}"
    end

    puts "Please disconnect the current master."
    gets

    results = []
    rescue_connection_failure do
      @coll.find.each {|r| results << r}
      [20, 30, 40].each do |a|
        assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a}"
      end
    end
  end

end
