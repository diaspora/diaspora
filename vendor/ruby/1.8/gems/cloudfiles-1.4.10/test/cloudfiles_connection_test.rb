$:.unshift File.dirname(__FILE__)
require 'test_helper'

class CloudfilesConnectionTest < Test::Unit::TestCase
  
  def setup
    CloudFiles::Authentication.expects(:new).returns(true)
    @connection = CloudFiles::Connection.new('dummy_user', 'dummy_key')
    @connection.storagehost = "test.setup.example"
    @connection.storagepath = "/dummypath/setup"
    @connection.cdnmgmthost = "test.cdn.example"
    @connection.cdnmgmtpath = "/dummycdnpath/setup"
  end
  
  def test_initialize
    assert_equal @connection.authuser, 'dummy_user'
    assert_equal @connection.authkey, 'dummy_key'
  end
  
  def test_authok
    # This would normally be set in CloudFiles::Authentication
    assert_equal @connection.authok?, false
    @connection.expects(:authok?).returns(true)
    assert_equal @connection.authok?, true
  end
  
  def test_snet
    # This would normally be set in CloudFiles::Authentication
    assert_equal @connection.snet?, false
    @connection.expects(:snet?).returns(true)
    assert_equal @connection.snet?, true
  end
      
  def test_cfreq_get
    build_net_http_object
    assert_nothing_raised do 
      response = @connection.cfreq("GET", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_cfreq_post
    build_net_http_object
    assert_nothing_raised do
      response = @connection.cfreq("POST", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_cfreq_put
    build_net_http_object
    assert_nothing_raised do
      response = @connection.cfreq("PUT", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_cfreq_delete
    build_net_http_object
    assert_nothing_raised do
      response = @connection.cfreq("DELETE", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_cfreq_with_static_data
    build_net_http_object
    assert_nothing_raised do
      response = @connection.cfreq("PUT", "test.server.example", "/dummypath", "80", "http", {}, "This is string data")
    end
  end
  
  def test_cfreq_with_stream_data
    build_net_http_object
    require 'tempfile'
    file = Tempfile.new("test")
    assert_nothing_raised do
      response = @connection.cfreq("PUT", "test.server.example", "/dummypath", "80", "http", {}, file)
    end
  end
  
  def test_cfreq_head
    build_net_http_object
    assert_nothing_raised do
      response = @connection.cfreq("HEAD", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_net_http_raises_connection_exception
    Net::HTTP.expects(:new).raises(ConnectionException)
    assert_raises(ConnectionException) do
      response = @connection.cfreq("GET", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_net_http_raises_one_eof_exception
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}
    response.stubs(:code).returns('204')
    server = stub(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server.stubs(:request).raises(EOFError).then.returns(response)
    Net::HTTP.stubs(:new).returns(server)
    assert_nothing_raised do
      response = @connection.cfreq("GET", "test.server.example", "/dummypath", "443", "https")
    end
  end
  
  def test_net_http_raises_one_expired_token
    CloudFiles::Authentication.expects(:new).returns(true)
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}
    response.stubs(:code).returns('401').then.returns('204')
    server = stub(:use_ssl= => true, :verify_mode= => true, :start => true)
    server.stubs(:request).returns(response)
    Net::HTTP.stubs(:new).returns(server)
    assert_nothing_raised do
      response = @connection.cfreq("GET", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_net_http_raises_continual_eof_exceptions
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}
    response.stubs(:code).returns('204')
    server = stub(:use_ssl= => true, :verify_mode= => true, :start => true)
    server.stubs(:finish).returns(true)
    server.stubs(:request).raises(EOFError)
    Net::HTTP.stubs(:new).returns(server)
    assert_raises(ConnectionException) do
      response = @connection.cfreq("GET", "test.server.example", "/dummypath", "80", "http")
    end
  end
  
  def test_get_info
    build_net_http_object(:response => {'x-account-bytes-used' => '9999', 'x-account-container-count' => '5'}, :code => '204')
    @connection.get_info
    assert_equal @connection.bytes, 9999
    assert_equal @connection.count, 5
  end
  
  def test_get_info_fails
    build_net_http_object(:response => {'x-account-bytes-used' => '9999', 'x-account-container-count' => '5'}, :code => '999')
    assert_raises(InvalidResponseException) do
      @connection.get_info
    end
  end
  
  def test_public_containers
    build_net_http_object(:body => "foo\nbar\nbaz", :code => '200', :response => {})
    public_containers = @connection.public_containers
    assert_equal public_containers.size, 3
    assert_equal public_containers.first, 'foo'
  end
  
  def test_public_containers_empty
    build_net_http_object
    public_containers = @connection.public_containers
    assert_equal public_containers.size, 0
    assert_equal public_containers.class, Array
  end
  
  def test_public_containers_exception
    build_net_http_object(:code => '999')
    assert_raises(InvalidResponseException) do
      public_containers = @connection.public_containers
    end
  end
  
  def test_delete_container
    build_net_http_object
    response = @connection.delete_container("good_container")
    assert_equal response, true
  end
  
  def test_delete_nonempty_container
    build_net_http_object(:code => '409')
    assert_raises(NonEmptyContainerException) do
      response = @connection.delete_container("not_empty")
    end
  end
  
  def test_delete_unknown_container
    build_net_http_object(:code => '999')
    assert_raises(NoSuchContainerException) do
      response = @connection.delete_container("not_empty")
    end
  end
  
  def test_create_container
    CloudFiles::Container.any_instance.stubs(:populate)
    build_net_http_object(:code => '201')
    container = @connection.create_container('good_container')
    assert_equal container.name, 'good_container'
  end
  
  def test_create_container_with_invalid_name
    CloudFiles::Container.stubs(:new)
    assert_raise(SyntaxException) do
      container = @connection.create_container('a'*300)
    end
  end
  
  def test_create_container_name_filter
    CloudFiles::Container.any_instance.stubs(:populate)
    build_net_http_object(:code => '201')
    assert_raises(SyntaxException) do 
      container = @connection.create_container('this/has/bad?characters')
    end
  end
  
  def test_container_exists_true
    build_net_http_object
    assert_equal @connection.container_exists?('this_container_exists'), true
  end
  
  def test_container_exists_false
    build_net_http_object(:code => '999')
    assert_equal @connection.container_exists?('this_does_not_exist'), false
  end
  
  def test_fetch_exisiting_container
    CloudFiles::Container.any_instance.stubs(:populate)
    build_net_http_object
    container = @connection.container('good_container')
    assert_equal container.name, 'good_container'
  end
  
  def test_fetch_nonexistent_container
    CloudFiles::Container.any_instance.stubs(:populate).raises(NoSuchContainerException)
    build_net_http_object
    assert_raise(NoSuchContainerException) do
      container = @connection.container('bad_container')
    end
  end
  
  def test_containers
    build_net_http_object(:body => "foo\nbar\nbaz\nboo", :code => '200')
    containers = @connection.containers
    assert_equal containers.size, 4
    assert_equal containers.first, 'foo'
  end
  
  def test_containers_with_limit
    build_net_http_object_with_cfreq_expectations({:body => "foo", :code => '200'},
                                                  {:path => includes('limit=1')})
    containers = @connection.containers(1)
    assert_equal containers.size, 1
    assert_equal containers.first, 'foo'
  end

  def test_containers_with_marker
    build_net_http_object_with_cfreq_expectations({:body => "boo", :code => '200'},
                                                  {:path => includes('marker=baz')})
    containers = @connection.containers(0, 'baz')
    assert_equal containers.size, 1
    assert_equal containers.first, 'boo'
  end

  def test_no_containers_yet
    build_net_http_object
    containers = @connection.containers
    assert_equal containers.size, 0
    assert_equal containers.class, Array
  end
  
  def test_containers_bad_result
    build_net_http_object(:code => '999')
    assert_raises(InvalidResponseException) do
      containers = @connection.containers
    end
  end
  
  def test_containers_detail
    body = %{<?xml version="1.0" encoding="UTF-8"?>
    <account name="MossoCloudFS_012559c7-030d-4bbd-8538-7468896b0e7f">
    <container><name>Books</name><count>0</count><bytes>0</bytes></container><container><name>cftest</name><count>0</count><bytes>0</bytes></container><container><name>cszsa</name><count>1</count><bytes>82804</bytes></container><container><name>CWX</name><count>3</count><bytes>3645134</bytes></container><container><name>test</name><count>2</count><bytes>20</bytes></container><container><name>video</name><count>2</count><bytes>34141298</bytes></container><container><name>webpics</name><count>1</count><bytes>177496</bytes></container></account>}
    build_net_http_object(:body => body, :code => '200')
    details = @connection.containers_detail
    assert_equal details['CWX'][:count], "3"
  end
  
  def test_empty_containers_detail
    build_net_http_object
    details = @connection.containers_detail
    assert_equal details, {}
  end
  
  def test_containers_detail_bad_response
    build_net_http_object(:code => '999')
    assert_raises(InvalidResponseException) do
      details = @connection.containers_detail
    end
  end
    
  private
  
  def build_net_http_object(args={:code => '204' }, cfreq_expectations={})
    args[:response] = {} unless args[:response]
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}.merge(args[:response])
    response.stubs(:code).returns(args[:code])
    response.stubs(:body).returns args[:body] || nil

    if !cfreq_expectations.empty?
      parameter_expectations = [anything(), anything(), anything(), anything(), anything(), anything(), anything(), anything()]
      parameter_expectations[0] = cfreq_expectations[:method] if cfreq_expectations[:method]
      parameter_expectations[2] = cfreq_expectations[:path] if cfreq_expectations[:path]
      
      @connection.expects(:cfreq).with(*parameter_expectations).returns(response)
    else  
      @connection.stubs(:cfreq).returns(response)
    end

  end

  def build_net_http_object_with_cfreq_expectations(args={:code => '204' }, cfreq_expectations={})
    build_net_http_object(args, cfreq_expectations)
  end
end
