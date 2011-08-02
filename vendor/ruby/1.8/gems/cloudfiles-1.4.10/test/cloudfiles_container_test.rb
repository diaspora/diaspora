$:.unshift File.dirname(__FILE__)
require 'test_helper'

class CloudfilesContainerTest < Test::Unit::TestCase
  
  def test_object_creation
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5'}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    @container = CloudFiles::Container.new(connection, 'test_container')
    assert_equal @container.name, 'test_container'
    assert_equal @container.class, CloudFiles::Container
    assert_equal @container.public?, false
    assert_equal @container.cdn_url, false
    assert_equal @container.cdn_ttl, false
  end
  
  def test_object_creation_no_such_container
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5'}
    response.stubs(:code).returns('999')
    connection.stubs(:cfreq => response)
    assert_raise(NoSuchContainerException) do
      @container = CloudFiles::Container.new(connection, 'test_container')
    end
  end
  
  def test_object_creation_with_cdn
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5', 'x-cdn-enabled' => 'True', 'x-cdn-uri' => 'http://cdn.test.example/container', 'x-ttl' => '86400'}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    @container = CloudFiles::Container.new(connection, 'test_container')
    assert_equal @container.name, 'test_container'
    assert_equal @container.cdn_enabled, true
    assert_equal @container.public?, true
    assert_equal @container.cdn_url, 'http://cdn.test.example/container'
    assert_equal @container.cdn_ttl, 86400
  end
  
  def test_to_s
    build_net_http_object
    assert_equal @container.to_s, 'test_container'
  end
  
  def test_make_private_succeeds
    build_net_http_object(:code => '201')
    assert_nothing_raised do
      @container.make_private
    end
  end
  
  def test_make_private_fails
    build_net_http_object(:code => '999')
    assert_raises(NoSuchContainerException) do
      @container.make_private
    end
  end
  
  def test_make_public_succeeds
    build_net_http_object(:code => '201')
    assert_nothing_raised do
      @container.make_public
    end
  end
  
  def test_make_public_fails
    build_net_http_object(:code => '999')
    assert_raises(NoSuchContainerException) do
      @container.make_public
    end
  end
  
  def test_empty_is_false
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5'}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    @container = CloudFiles::Container.new(connection, 'test_container')
    assert_equal @container.empty?, false
  end
  
  def test_empty_is_true
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '0', 'x-container-object-count' => '0'}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    @container = CloudFiles::Container.new(connection, 'test_container')
    assert_equal @container.empty?, true
  end
  
  def test_log_retention_is_true
    connection = mock(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '0', 'x-container-object-count' => '0', 'x-cdn-enabled' => 'True', 'x-log-retention' => 'True'}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    @container = CloudFiles::Container.new(connection, 'test_container')
    assert_equal @container.log_retention?, true
  end
  
  def test_object_fetch
    build_net_http_object(:code => '204', :response => {'last-modified' => 'Wed, 28 Jan 2009 16:16:26 GMT'})
    object = @container.object('good_object')
    assert_equal object.class, CloudFiles::StorageObject
  end
  
  def test_create_object
    build_net_http_object()
    object = @container.create_object('new_object')
    assert_equal object.class, CloudFiles::StorageObject
  end
  
  def test_object_exists_true
    build_net_http_object
    assert_equal @container.object_exists?('good_object'), true
  end
  
  def test_object_exists_false
    build_net_http_object(:code => '999')
    assert_equal @container.object_exists?('bad_object'), false
  end
  
  def test_delete_object_succeeds
    build_net_http_object
    assert_nothing_raised do
      @container.delete_object('good_object')
    end
  end
  
  def test_delete_invalid_object_fails
    build_net_http_object(:code => '404')
    assert_raise(NoSuchObjectException) do
      @container.delete_object('nonexistent_object')
    end
  end
  
  def test_delete_invalid_response_code_fails
    build_net_http_object(:code => '999')
    assert_raise(InvalidResponseException) do
      @container.delete_object('broken_object')
    end
  end
  
  def test_fetch_objects
    build_net_http_object(:code => '200', :body => "foo\nbar\nbaz")
    objects = @container.objects
    assert_equal objects.class, Array
    assert_equal objects.size, 3
    assert_equal objects.first, 'foo'
  end
  
  def test_fetch_objects_with_limit
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => "foo"},
                                                  {:path => includes("limit=1")})
    objects = @container.objects(:limit => 1)
    assert_equal objects.class, Array
    assert_equal objects.size, 1
    assert_equal objects.first, 'foo'
  end

  def test_fetch_objects_with_marker
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => "bar"},
                                                  {:path => includes("marker=foo")})
    objects = @container.objects(:marker => 'foo')
    assert_equal objects.class, Array
    assert_equal objects.size, 1
    assert_equal objects.first, 'bar'
  end

  def test_fetch_objects_with_deprecated_offset_param
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => "bar"},
                                                  {:path => includes("marker=foo")})
    objects = @container.objects(:offset => 'foo')
    assert_equal objects.class, Array
    assert_equal objects.size, 1
    assert_equal objects.first, 'bar'
  end
  
  def object_detail_body(skip_kisscam=false)
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<container name="video">']
    unless skip_kisscam
      lines << '<object><name>kisscam.mov</name><hash>96efd5a0d78b74cfe2a911c479b98ddd</hash><bytes>9196332</bytes><content_type>video/quicktime</content_type><last_modified>2008-12-18T10:34:43.867648</last_modified></object>
>'
    end
    lines << '<object><name>penaltybox.mov</name><hash>d2a4c0c24d8a7b4e935bee23080e0685</hash><bytes>24944966</bytes><content_type>video/quicktime</content_type><last_modified>2008-12-18T10:35:19.273927</last_modified></object>'
    lines << '</container>'

    lines.join("\n\n")
  end
  
  def test_fetch_objects_detail
    build_net_http_object(:code => '200', :body => object_detail_body)
    details = @container.objects_detail
    assert_equal details.size, 2
    assert_equal details['kisscam.mov'][:bytes], '9196332'
  end
  
  def test_fetch_objects_details_with_limit
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => object_detail_body},
                                                  {:path => includes("limit=2")})
    details = @container.objects_detail(:limit => 2)
    assert_equal details.size, 2
    assert_equal details['kisscam.mov'][:bytes], '9196332'
  end

  def test_fetch_objects_detail_with_marker
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => object_detail_body(true)},
                                                  {:path => includes("marker=kisscam.mov")})
    details = @container.objects_detail(:marker => 'kisscam.mov')
    assert_equal details.size, 1
    assert_equal details['penaltybox.mov'][:bytes], '24944966'
  end

  def test_fetch_objects_detail_with_deprecated_offset_param
    build_net_http_object_with_cfreq_expectations({:code => '200', :body => object_detail_body(true)},
                                                  {:path => includes("marker=kisscam.mov")})
    details = @container.objects_detail(:offset => 'kisscam.mov')
    assert_equal details.size, 1
    assert_equal details['penaltybox.mov'][:bytes], '24944966'
  end
  
  
  def test_fetch_object_detail_empty
    build_net_http_object
    details = @container.objects_detail
    assert_equal details, {}
  end
  
  def test_fetch_object_detail_error
    build_net_http_object(:code => '999')
    assert_raise(InvalidResponseException) do
      details = @container.objects_detail
    end
  end
  
  def test_setting_log_retention
    build_net_http_object(:code => '201')
    assert(@container.log_retention='false')
  end
  
  private
  
  def build_net_http_object(args={:code => '204' }, cfreq_expectations={})
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    args[:response] = {} unless args[:response]
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token', 'last-modified' => Time.now.to_s}.merge(args[:response])
    response.stubs(:code).returns(args[:code])
    response.stubs(:body).returns args[:body] || nil
    
    if !cfreq_expectations.empty?
      #cfreq(method,server,path,port,scheme,headers = {},data = nil,attempts = 0,&block)
      
      parameter_expectations = [anything(), anything(), anything(), anything(), anything(), anything(), anything(), anything()]
      parameter_expectations[0] = cfreq_expectations[:method] if cfreq_expectations[:method]
      parameter_expectations[2] = cfreq_expectations[:path] if cfreq_expectations[:path]
      
      connection.expects(:cfreq).with(*parameter_expectations).returns(response)
    else  
      connection.stubs(:cfreq => response)
    end
    
    @container = CloudFiles::Container.new(connection, 'test_container')
    @container.stubs(:connection).returns(connection)
  end
  
  def build_net_http_object_with_cfreq_expectations(args={:code => '204'}, cfreq_expectations={})
    build_net_http_object(args, cfreq_expectations)
  end
end
