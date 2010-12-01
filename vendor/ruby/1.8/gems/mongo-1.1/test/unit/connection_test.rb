require './test/test_helper'
include Mongo

class ConnectionTest < Test::Unit::TestCase
  context "Initialization: " do
    setup do
      def new_mock_socket
        socket = Object.new
        socket.stubs(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        socket.stubs(:close)
        socket
      end

      def new_mock_db
        db = Object.new
      end
    end

    context "given a single node" do
      setup do
        @conn = Connection.new('localhost', 27017, :connect => false)
        TCPSocket.stubs(:new).returns(new_mock_socket)

        admin_db = new_mock_db
        admin_db.expects(:command).returns({'ok' => 1, 'ismaster' => 1})
        @conn.expects(:[]).with('admin').returns(admin_db)
        @conn.connect
      end

      should "set localhost and port to master" do
        assert_equal 'localhost', @conn.host
        assert_equal 27017, @conn.port
      end

      should "set connection pool to 1" do
        assert_equal 1, @conn.size
      end

      should "default slave_ok to false" do
        assert !@conn.slave_ok?
      end
    end

    context "connecting to a replica set" do
      setup do
        TCPSocket.stubs(:new).returns(new_mock_socket)
        @conn = Connection.new('localhost', 27017, :connect => false)

        admin_db = new_mock_db
        @hosts = ['localhost:27018', 'localhost:27019']
        admin_db.expects(:command).returns({'ok' => 1, 'ismaster' => 1, 'hosts' => @hosts})
        @conn.expects(:[]).with('admin').returns(admin_db)
        @conn.connect
      end

      should "store the hosts returned from the ismaster command" do
        @hosts.each do |host|
          host, port = host.split(":")
          port = port.to_i
          assert @conn.nodes.include?([host, port]), "Connection doesn't include host #{host.inspect}."
        end
      end
    end

    context "connecting to a replica set and providing seed nodes" do
      setup do
        TCPSocket.stubs(:new).returns(new_mock_socket)
        @conn = Connection.multi([['localhost', 27017], ['localhost', 27019]], :connect => false)

        admin_db = new_mock_db
        @hosts = ['localhost:27017', 'localhost:27018', 'localhost:27019']
        admin_db.stubs(:command).returns({'ok' => 1, 'ismaster' => 1, 'hosts' => @hosts})
        @conn.stubs(:[]).with('admin').returns(admin_db)
        @conn.connect
      end

      should "not store any hosts redundantly" do
        assert_equal 3, @conn.nodes.size

        @hosts.each do |host|
          host, port = host.split(":")
          port = port.to_i
          assert @conn.nodes.include?([host, port]), "Connection doesn't include host #{host.inspect}."
        end
      end
    end

    context "initializing a paired connection" do
      should "require left and right nodes" do
        assert_raise MongoArgumentError do
          Connection.multi(['localhost', 27018], :connect => false)
        end

        assert_raise MongoArgumentError do
          Connection.multi(['localhost', 27018], :connect => false)
        end
      end

      should "store both nodes" do
        @conn = Connection.multi([['localhost', 27017], ['localhost', 27018]], :connect => false)

        assert_equal ['localhost', 27017], @conn.nodes[0]
        assert_equal ['localhost', 27018], @conn.nodes[1]
      end
    end

    context "initializing with a mongodb uri" do
      should "parse a simple uri" do
        @conn = Connection.from_uri("mongodb://localhost", :connect => false)
        assert_equal ['localhost', 27017], @conn.nodes[0]
      end

      should "allow a complex host names" do
        host_name = "foo.bar-12345.org"
        @conn = Connection.from_uri("mongodb://#{host_name}", :connect => false)
        assert_equal [host_name, 27017], @conn.nodes[0]
      end

      should "parse a uri specifying multiple nodes" do
        @conn = Connection.from_uri("mongodb://localhost:27017,mydb.com:27018", :connect => false)
        assert_equal ['localhost', 27017], @conn.nodes[0]
        assert_equal ['mydb.com', 27018], @conn.nodes[1]
      end

      should "parse a uri specifying multiple nodes with auth" do
        @conn = Connection.from_uri("mongodb://kyle:s3cr3t@localhost:27017/app,mickey:m0u5e@mydb.com:27018/dsny", :connect => false)
        assert_equal ['localhost', 27017], @conn.nodes[0]
        assert_equal ['mydb.com', 27018], @conn.nodes[1]
        auth_hash = {'username' => 'kyle', 'password' => 's3cr3t', 'db_name' => 'app'}
        assert_equal auth_hash, @conn.auths[0]
        auth_hash = {'username' => 'mickey', 'password' => 'm0u5e', 'db_name' => 'dsny'}
        assert_equal auth_hash, @conn.auths[1]
      end

      should "parse a uri with a hyphen & underscore in the username or password" do
        @conn = Connection.from_uri("mongodb://hyphen-user_name:p-s_s@localhost:27017/db", :connect => false)
        assert_equal ['localhost', 27017], @conn.nodes[0]
        auth_hash = { 'db_name' => 'db', 'username' => 'hyphen-user_name', "password" => 'p-s_s' }
        assert_equal auth_hash, @conn.auths[0]
      end

      should "attempt to connect" do
        TCPSocket.stubs(:new).returns(new_mock_socket)
        @conn = Connection.from_uri("mongodb://localhost", :connect => false)

        admin_db = new_mock_db
        admin_db.expects(:command).returns({'ok' => 1, 'ismaster' => 1})
        @conn.expects(:[]).with('admin').returns(admin_db)
        @conn.expects(:apply_saved_authentication)
        @conn.connect
      end

      should "raise an error on invalid uris" do
        assert_raise MongoArgumentError do
          Connection.from_uri("mongo://localhost", :connect => false)
        end

        assert_raise MongoArgumentError do
          Connection.from_uri("mongodb://localhost:abc", :connect => false)
        end

        assert_raise MongoArgumentError do
          Connection.from_uri("mongodb://localhost:27017, my.db.com:27018, ", :connect => false)
        end
      end

      should "require all of username, password, and database if any one is specified" do
        assert_raise MongoArgumentError do
          Connection.from_uri("mongodb://localhost/db", :connect => false)
        end

        assert_raise MongoArgumentError do
          Connection.from_uri("mongodb://kyle:password@localhost", :connect => false)
        end
      end
    end
  end
end
