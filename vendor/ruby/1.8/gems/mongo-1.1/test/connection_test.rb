require './test/test_helper'
require 'logger'
require 'stringio'
require 'thread'

class TestConnection < Test::Unit::TestCase

  include Mongo
  include BSON

  def setup
    @host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    @port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT
    @mongo = Connection.new(@host, @port)
  end

  def teardown
    @mongo[MONGO_TEST_DB].get_last_error
  end

  def test_slave_ok_with_multiple_nodes

  end

  def test_server_info
    server_info = @mongo.server_info
    assert server_info.keys.include?("version")
    assert Mongo::Support.ok?(server_info)
  end

  def test_connection_uri
    con = Connection.from_uri("mongodb://localhost:27017")
    assert_equal "localhost", con.host
    assert_equal 27017, con.port
  end

  def test_server_version
    assert_match /\d\.\d+(\.\d+)?/, @mongo.server_version.to_s
  end

  def test_invalid_database_names
    assert_raise TypeError do @mongo.db(4) end

    assert_raise Mongo::InvalidNSName do @mongo.db('') end
    assert_raise Mongo::InvalidNSName do @mongo.db('te$t') end
    assert_raise Mongo::InvalidNSName do @mongo.db('te.t') end
    assert_raise Mongo::InvalidNSName do @mongo.db('te\\t') end
    assert_raise Mongo::InvalidNSName do @mongo.db('te/t') end
    assert_raise Mongo::InvalidNSName do @mongo.db('te st') end
  end

  def test_database_info
    @mongo.drop_database(MONGO_TEST_DB)
    @mongo.db(MONGO_TEST_DB).collection('info-test').insert('a' => 1)

    info = @mongo.database_info
    assert_not_nil info
    assert_kind_of Hash, info
    assert_not_nil info[MONGO_TEST_DB]
    assert info[MONGO_TEST_DB] > 0

    @mongo.drop_database(MONGO_TEST_DB)
  end

  def test_copy_database
    @mongo.db('old').collection('copy-test').insert('a' => 1)
    @mongo.copy_database('old', 'new')
    old_object = @mongo.db('old').collection('copy-test').find.next_document
    new_object = @mongo.db('new').collection('copy-test').find.next_document
    assert_equal old_object, new_object
    @mongo.drop_database('old')
    @mongo.drop_database('new')
  end

  def test_copy_database_with_auth
    @mongo.db('old').collection('copy-test').insert('a' => 1)
    @mongo.db('old').add_user('bob', 'secret')

    assert_raise Mongo::OperationFailure do
      @mongo.copy_database('old', 'new', 'localhost', 'bob', 'badpassword')
    end

    result = @mongo.copy_database('old', 'new', 'localhost', 'bob', 'secret')
    assert Mongo::Support.ok?(result)

    @mongo.drop_database('old')
    @mongo.drop_database('new')
  end

  def test_database_names
    @mongo.drop_database(MONGO_TEST_DB)
    @mongo.db(MONGO_TEST_DB).collection('info-test').insert('a' => 1)

    names = @mongo.database_names
    assert_not_nil names
    assert_kind_of Array, names
    assert names.length >= 1
    assert names.include?(MONGO_TEST_DB)
  end

  def test_logging
    output = StringIO.new
    logger = Logger.new(output)
    logger.level = Logger::DEBUG
    db = Connection.new(@host, @port, :logger => logger).db(MONGO_TEST_DB)
    assert output.string.include?("admin['$cmd'].find")
  end

  def test_connection_logger
    output = StringIO.new
    logger = Logger.new(output)
    logger.level = Logger::DEBUG
    connection = Connection.new(@host, @port, :logger => logger)
    assert_equal logger, connection.logger
    
    connection.logger.debug 'testing'
    assert output.string.include?('testing')
  end

  def test_drop_database
    db = @mongo.db('ruby-mongo-will-be-deleted')
    coll = db.collection('temp')
    coll.remove
    coll.insert(:name => 'temp')
    assert_equal 1, coll.count()
    assert @mongo.database_names.include?('ruby-mongo-will-be-deleted')

    @mongo.drop_database('ruby-mongo-will-be-deleted')
    assert !@mongo.database_names.include?('ruby-mongo-will-be-deleted')
  end

  def test_nodes
    db = Connection.multi([['foo', 27017], ['bar', 27018]], :connect => false)
    nodes = db.nodes
    assert_equal 2, nodes.length
    assert_equal ['foo', 27017], nodes[0]
    assert_equal ['bar', 27018], nodes[1]
  end

  def test_slave_ok_with_multiple_nodes
    assert_raise MongoArgumentError do
      Connection.multi([['foo', 27017], ['bar', 27018]], :connect => false, :slave_ok => true)
    end
  end

  def test_fsync_lock
    assert !@mongo.locked?
    @mongo.lock!
    assert @mongo.locked?
    assert_equal 1, @mongo['admin']['$cmd.sys.inprog'].find_one['fsyncLock'], "Not fsync-locked"
    assert_equal "unlock requested", @mongo.unlock!['info']
    unlocked = false
    counter  = 0
    while counter < 5
      if @mongo['admin']['$cmd.sys.inprog'].find_one['fsyncLock'].nil?
        unlocked = true
        break
      else
        sleep(1)
        counter += 1
      end
    end
    assert !@mongo.locked?
    assert unlocked, "mongod failed to unlock"
  end

  context "Saved authentications" do
    setup do
      @conn = Mongo::Connection.new
      @auth = {'db_name' => 'test', 'username' => 'bob', 'password' => 'secret'}
      @conn.add_auth(@auth['db_name'], @auth['username'], @auth['password'])
    end

    should "save the authentication" do
      assert_equal @auth, @conn.auths[0]
    end

    should "replace the auth if given a new auth for the same db" do
      auth = {'db_name' => 'test', 'username' => 'mickey', 'password' => 'm0u53'}
      @conn.add_auth(auth['db_name'], auth['username'], auth['password'])
      assert_equal 1, @conn.auths.length
      assert_equal auth, @conn.auths[0]
    end

    should "remove auths by database" do
      @conn.remove_auth('non-existent database')
      assert_equal 1, @conn.auths.length

      @conn.remove_auth('test')
      assert_equal 0, @conn.auths.length
    end

    should "remove all auths" do
      @conn.clear_auths
      assert_equal 0, @conn.auths.length
    end
  end

  context "Connection exceptions" do
    setup do
      @conn = Mongo::Connection.new('localhost', 27017, :pool_size => 10, :timeout => 10)
      @coll = @conn[MONGO_TEST_DB]['test-connection-exceptions']
    end

    should "release connection if an exception is raised on send_message" do
      @conn.stubs(:send_message_on_socket).raises(ConnectionFailure)
      assert_equal 0, @conn.checked_out.size
      assert_raise ConnectionFailure do
        @coll.insert({:test => "insert"})
      end
      assert_equal 0, @conn.checked_out.size
    end

    should "release connection if an exception is raised on send_with_safe_check" do
      @conn.stubs(:receive).raises(ConnectionFailure)
      assert_equal 0, @conn.checked_out.size
      assert_raise ConnectionFailure do
        @coll.insert({:test => "insert"}, :safe => true)
      end
      assert_equal 0, @conn.checked_out.size
    end

    should "release connection if an exception is raised on receive_message" do
      @conn.stubs(:receive).raises(ConnectionFailure)
      assert_equal 0, @conn.checked_out.size
      assert_raise ConnectionFailure do
        @coll.find.to_a
      end
      assert_equal 0, @conn.checked_out.size
    end
  end
end
