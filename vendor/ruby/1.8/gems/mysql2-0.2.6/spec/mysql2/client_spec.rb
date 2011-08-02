# encoding: UTF-8
require 'spec_helper'

describe Mysql2::Client do
  before(:each) do
    @client = Mysql2::Client.new
  end

  if defined? Encoding
    it "should raise an exception on create for invalid encodings" do
      lambda {
        c = Mysql2::Client.new(:encoding => "fake")
      }.should raise_error(Mysql2::Error)
    end
  end

  it "should accept connect flags and pass them to #connect" do
    klient = Class.new(Mysql2::Client) do
      attr_reader :connect_args
      def connect *args
        @connect_args ||= []
        @connect_args << args
      end
    end
    client = klient.new :flags => Mysql2::Client::FOUND_ROWS
    (client.connect_args.last.last & Mysql2::Client::FOUND_ROWS).should be_true
  end

  it "should default flags to (REMEMBER_OPTIONS, LONG_PASSWORD, LONG_FLAG, TRANSACTIONS, PROTOCOL_41, SECURE_CONNECTION)" do
    klient = Class.new(Mysql2::Client) do
      attr_reader :connect_args
      def connect *args
        @connect_args ||= []
        @connect_args << args
      end
    end
    client = klient.new
    (client.connect_args.last.last & (Mysql2::Client::REMEMBER_OPTIONS |
                                     Mysql2::Client::LONG_PASSWORD |
                                     Mysql2::Client::LONG_FLAG |
                                     Mysql2::Client::TRANSACTIONS |
                                     Mysql2::Client::PROTOCOL_41 |
                                     Mysql2::Client::SECURE_CONNECTION)).should be_true
  end

  it "should have a global default_query_options hash" do
    Mysql2::Client.should respond_to(:default_query_options)
  end

  it "should be able to connect via SSL options" do
    pending("DON'T WORRY, THIS TEST PASSES :) - but is machine-specific. You need to have MySQL running with SSL configured and enabled. Then update the paths in this test to your needs and remove the pending state.")
    ssl_client = nil
    lambda {
      ssl_client = Mysql2::Client.new(
        :sslkey => '/path/to/client-key.pem',
        :sslcert => '/path/to/client-cert.pem',
        :sslca => '/path/to/ca-cert.pem',
        :sslcapath => '/path/to/newcerts/',
        :sslcipher => 'DHE-RSA-AES256-SHA'
      )
    }.should_not raise_error(Mysql2::Error)

    results = ssl_client.query("SHOW STATUS WHERE Variable_name = \"Ssl_version\" OR Variable_name = \"Ssl_cipher\"").to_a
    results[0]['Variable_name'].should eql('Ssl_cipher')
    results[0]['Value'].should_not be_nil
    results[0]['Value'].class.should eql(String)

    results[1]['Variable_name'].should eql('Ssl_version')
    results[1]['Value'].should_not be_nil
    results[1]['Value'].class.should eql(String)
  end

  it "should respond to #close" do
    @client.should respond_to(:close)
  end

  it "should be able to close properly" do
    @client.close.should be_nil
    lambda {
      @client.query "SELECT 1"
    }.should raise_error(Mysql2::Error)
  end

  it "should respond to #query" do
    @client.should respond_to(:query)
  end

  context "#query" do
    it "should accept an options hash that inherits from Mysql2::Client.default_query_options" do
      @client.query "SELECT 1", :something => :else
      @client.query_options.should eql(@client.query_options.merge(:something => :else))
    end

    it "should return results as a hash by default" do
      @client.query("SELECT 1").first.class.should eql(Hash)
    end

    it "should be able to return results as an array" do
      @client.query("SELECT 1", :as => :array).first.class.should eql(Array)
      @client.query("SELECT 1").each(:as => :array)
    end

    it "should be able to return results with symbolized keys" do
      @client.query("SELECT 1", :symbolize_keys => true).first.keys[0].class.should eql(Symbol)
    end

    it "should not allow another query to be sent without fetching a result first" do
      @client.query("SELECT 1", :async => true)
      lambda {
        @client.query("SELECT 1")
      }.should raise_error(Mysql2::Error)
    end

    it "should require an open connection" do
      @client.close
      lambda {
        @client.query "SELECT 1"
      }.should raise_error(Mysql2::Error)
    end

    # XXX this test is not deterministic (because Unix signal handling is not)
    # and may fail on a loaded system
    if RUBY_PLATFORM !~ /mingw|mswin/
      it "should run signal handlers while waiting for a response" do
        mark = {}
        trap(:USR1) { mark[:USR1] = Time.now }
        begin
          mark[:START] = Time.now
          pid = fork do
            sleep 1 # wait for client "SELECT sleep(2)" query to start
            Process.kill(:USR1, Process.ppid)
            sleep # wait for explicit kill to prevent GC disconnect
          end
          @client.query("SELECT sleep(2)")
          mark[:END] = Time.now
          mark.include?(:USR1).should be_true
          (mark[:USR1] - mark[:START]).should >= 1
          (mark[:USR1] - mark[:START]).should < 1.1
          (mark[:END] - mark[:USR1]).should > 0.9
          (mark[:END] - mark[:START]).should >= 2
          (mark[:END] - mark[:START]).should < 2.1
          Process.kill(:TERM, pid)
          Process.waitpid2(pid)
        ensure
          trap(:USR1, 'DEFAULT')
        end
      end
    end
  end

  it "should respond to #escape" do
    @client.should respond_to(:escape)
  end

  context "#escape" do
    it "should return a new SQL-escape version of the passed string" do
      @client.escape("abc'def\"ghi\0jkl%mno").should eql("abc\\'def\\\"ghi\\0jkl%mno")
    end

    it "should return the passed string if nothing was escaped" do
      str = "plain"
      @client.escape(str).object_id.should eql(str.object_id)
    end

    it "should not overflow the thread stack" do
      lambda {
        Thread.new { @client.escape("'" * 256 * 1024) }.join
      }.should_not raise_error(SystemStackError)
    end

    it "should not overflow the process stack" do
      lambda {
        Thread.new { @client.escape("'" * 1024 * 1024 * 4) }.join
      }.should_not raise_error(SystemStackError)
    end

    it "should require an open connection" do
      @client.close
      lambda {
        @client.escape ""
      }.should raise_error(Mysql2::Error)
    end
  end

  it "should respond to #info" do
    @client.should respond_to(:info)
  end

  it "#info should return a hash containing the client version ID and String" do
    info = @client.info
    info.class.should eql(Hash)
    info.should have_key(:id)
    info[:id].class.should eql(Fixnum)
    info.should have_key(:version)
    info[:version].class.should eql(String)
  end

  if defined? Encoding
    context "strings returned by #info" do
      it "should default to the connection's encoding if Encoding.default_internal is nil" do
        Encoding.default_internal = nil
        @client.info[:version].encoding.should eql(Encoding.find('utf-8'))

        client2 = Mysql2::Client.new :encoding => 'ascii'
        client2.info[:version].encoding.should eql(Encoding.find('us-ascii'))
      end

      it "should use Encoding.default_internal" do
        Encoding.default_internal = Encoding.find('utf-8')
        @client.info[:version].encoding.should eql(Encoding.default_internal)
        Encoding.default_internal = Encoding.find('us-ascii')
        @client.info[:version].encoding.should eql(Encoding.default_internal)
      end
    end
  end

  it "should respond to #server_info" do
    @client.should respond_to(:server_info)
  end

  it "#server_info should return a hash containing the client version ID and String" do
    server_info = @client.server_info
    server_info.class.should eql(Hash)
    server_info.should have_key(:id)
    server_info[:id].class.should eql(Fixnum)
    server_info.should have_key(:version)
    server_info[:version].class.should eql(String)
  end

  it "#server_info should require an open connection" do
    @client.close
    lambda {
      @client.server_info
    }.should raise_error(Mysql2::Error)
  end

  if defined? Encoding
    context "strings returned by #server_info" do
      it "should default to the connection's encoding if Encoding.default_internal is nil" do
        Encoding.default_internal = nil
        @client.server_info[:version].encoding.should eql(Encoding.find('utf-8'))

        client2 = Mysql2::Client.new :encoding => 'ascii'
        client2.server_info[:version].encoding.should eql(Encoding.find('us-ascii'))
      end

      it "should use Encoding.default_internal" do
        Encoding.default_internal = Encoding.find('utf-8')
        @client.server_info[:version].encoding.should eql(Encoding.default_internal)
        Encoding.default_internal = Encoding.find('us-ascii')
        @client.server_info[:version].encoding.should eql(Encoding.default_internal)
      end
    end
  end

  it "should respond to #socket" do
    @client.should respond_to(:socket)
  end

  it "#socket should return a Fixnum (file descriptor from C)" do
    @client.socket.class.should eql(Fixnum)
    @client.socket.should_not eql(0)
  end

  it "#socket should require an open connection" do
    @client.close
    lambda {
      @client.socket
    }.should raise_error(Mysql2::Error)
  end

  it "should raise a Mysql2::Error exception upon connection failure" do
    lambda {
      bad_client = Mysql2::Client.new :host => "dfjhdi9wrhw", :username => 'asdfasdf8d2h'
    }.should raise_error(Mysql2::Error)

    lambda {
      good_client = Mysql2::Client.new
    }.should_not raise_error(Mysql2::Error)
  end

  it "threaded queries should be supported" do
    threads, results = [], {}
    connect = lambda{ Mysql2::Client.new(:host => "localhost", :username => "root") }
    Timeout.timeout(0.7) do
      5.times {
        threads << Thread.new do
          results[Thread.current.object_id] = connect.call.query("SELECT sleep(0.5) as result")
        end
      }
    end
    threads.each{|t| t.join }
    results.keys.sort.should eql(threads.map{|t| t.object_id }.sort)
  end

  it "evented async queries should be supported" do
    # should immediately return nil
    @client.query("SELECT sleep(0.1)", :async => true).should eql(nil)

    io_wrapper = IO.for_fd(@client.socket)
    loops = 0
    loop do
      if IO.select([io_wrapper], nil, nil, 0.05)
        break
      else
        loops += 1
      end
    end

    # make sure we waited some period of time
    (loops >= 1).should be_true

    result = @client.async_result
    result.class.should eql(Mysql2::Result)
  end

  context 'write operations api' do
    before(:each) do
      @client.query "USE test"
      @client.query "CREATE TABLE lastIdTest (`id` int(11) NOT NULL AUTO_INCREMENT, blah INT(11), PRIMARY KEY (`id`))"
    end

    after(:each) do
      @client.query "DROP TABLE lastIdTest"
    end

    it "should respond to #last_id" do
      @client.should respond_to(:last_id)
    end

    it "#last_id should return a Fixnum, the from the last INSERT/UPDATE" do
      @client.last_id.should eql(0)
      @client.query "INSERT INTO lastIdTest (blah) VALUES (1234)"
      @client.last_id.should eql(1)
    end

    it "should respond to #last_id" do
      @client.should respond_to(:last_id)
    end

    it "#last_id should return a Fixnum, the from the last INSERT/UPDATE" do
      @client.query "INSERT INTO lastIdTest (blah) VALUES (1234)"
      @client.affected_rows.should eql(1)
      @client.query "UPDATE lastIdTest SET blah=4321 WHERE id=1"
      @client.affected_rows.should eql(1)
    end
  end
end
