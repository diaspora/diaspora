$:.unshift File.dirname(__FILE__)
require 'test_helper'

class CloudfilesAuthenticationTest < Test::Unit::TestCase
  

  def test_good_authentication
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}
    response.stubs(:code).returns('204')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server.stubs(:get).returns(response)
    CloudFiles::Authentication.any_instance.stubs(:get_server).returns(server)
    @connection = stub(:authuser => 'dummy_user', :authkey => 'dummy_key', :cdnmgmthost= => true, :cdnmgmtpath= => true, :cdnmgmtport= => true, :cdnmgmtscheme= => true, :storagehost= => true, :storagepath= => true, :storageport= => true, :storagescheme= => true, :authtoken= => true, :authok= => true, :snet? => false, :authurl => 'https://auth.api.rackspacecloud.com/v1.0')
    result = CloudFiles::Authentication.new(@connection)
    assert_equal result.class, CloudFiles::Authentication
  end
  
  def test_snet_authentication
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token'}
    response.stubs(:code).returns('204')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true, :finish => true)
    server.stubs(:get).returns(response)
    CloudFiles::Authentication.any_instance.stubs(:get_server).returns(server)
    @connection = stub(:authuser => 'dummy_user', :authkey => 'dummy_key', :cdnmgmthost= => true, :cdnmgmtpath= => true, :cdnmgmtport= => true, :cdnmgmtscheme= => true, :storagehost= => true, :storagepath= => true, :storageport= => true, :storagescheme= => true, :authtoken= => true, :authok= => true, :snet? => true, :authurl => 'https://auth.api.rackspacecloud.com/v1.0')
    result = CloudFiles::Authentication.new(@connection)
    assert_equal result.class, CloudFiles::Authentication
  end
  
  def test_bad_authentication
    response = mock()
    response.stubs(:code).returns('499')
    server = mock(:use_ssl= => true, :verify_mode= => true, :start => true)
    server.stubs(:get).returns(response)
    CloudFiles::Authentication.any_instance.stubs(:get_server).returns(server)
    @connection = stub(:authuser => 'bad_user', :authkey => 'bad_key', :authok= => true, :authtoken= => true,  :authurl => 'https://auth.api.rackspacecloud.com/v1.0')
    assert_raises(AuthenticationException) do
      result = CloudFiles::Authentication.new(@connection)
    end
  end
    
  def test_bad_hostname
    Net::HTTP.stubs(:new).raises(ConnectionException)
    @connection = stub(:authuser => 'bad_user', :authkey => 'bad_key', :authok= => true, :authtoken= => true, :authurl => 'https://auth.api.rackspacecloud.com/v1.0')
    assert_raises(ConnectionException) do
      result = CloudFiles::Authentication.new(@connection)
    end
  end
    
end
