$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: This test requires bouncing the server
class AutoreconnectTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new
    @db = @conn.db('mongo-ruby-test')
    @db.drop_collection("test-connect")
    @coll = @db.collection("test-connect")
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

    puts "Please disconnect and then reconnect the current master."
    gets

    begin
      @coll.find.to_a
      rescue Mongo::ConnectionFailure
    end

    results = []
      @coll.find.each {|r| results << r}
      [20, 30, 40].each do |a|
        assert results.any? {|r| r['a'] == a}, "Could not find record for a => #{a}"
      end
  end
end
