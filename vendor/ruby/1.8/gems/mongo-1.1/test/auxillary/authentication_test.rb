$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# NOTE: This test requires bouncing the server.
# It also requires that a user exists on the admin database.
class AuthenticationTest < Test::Unit::TestCase
  include Mongo

  def setup
    @conn = Mongo::Connection.new
    @db1 = @conn.db('mongo-ruby-test-auth1')
    @db2 = @conn.db('mongo-ruby-test-auth2')
    @admin = @conn.db('admin')
  end

  def teardown
    @db1.authenticate('user1', 'secret')
    @db2.authenticate('user2', 'secret')
    @conn.drop_database('mongo-ruby-test-auth1')
    @conn.drop_database('mongo-ruby-test-auth2')
  end

  def test_authenticate
    @admin.authenticate('bob', 'secret')
    @db1.add_user('user1', 'secret')
    @db2.add_user('user2', 'secret')
    @admin.logout

    assert_raise Mongo::OperationFailure do
      @db1['stuff'].insert({:a => 2}, :safe => true)
    end

    assert_raise Mongo::OperationFailure do
      @db2['stuff'].insert({:a => 2}, :safe => true)
    end

    @db1.authenticate('user1', 'secret')
    @db2.authenticate('user2', 'secret')

    assert @db1['stuff'].insert({:a => 2}, :safe => true)
    assert @db2['stuff'].insert({:a => 2}, :safe => true)

    puts "Please bounce the server."
    gets

    # Here we reconnect.
    begin
      @db1['stuff'].find.to_a
      rescue Mongo::ConnectionFailure
    end

    assert @db1['stuff'].insert({:a => 2}, :safe => true)
    assert @db2['stuff'].insert({:a => 2}, :safe => true)

    @db1.logout
    assert_raise Mongo::OperationFailure do
      @db1['stuff'].insert({:a => 2}, :safe => true)
    end

    @db2.logout
    assert_raise Mongo::OperationFailure do
      assert @db2['stuff'].insert({:a => 2}, :safe => true)
    end
  end

end
