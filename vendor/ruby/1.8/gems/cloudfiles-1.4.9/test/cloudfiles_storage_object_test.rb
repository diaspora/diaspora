require File.dirname(__FILE__) + '/test_helper'

class CloudfilesStorageObjectTest < Test::Unit::TestCase
  
  def test_object_creation
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5', 'last-modified' => Time.now.to_s}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    container = CloudFiles::Container.new(connection, 'test_container')
    @object = CloudFiles::StorageObject.new(container, 'test_object')
    assert_equal @object.name, 'test_object'
    assert_equal @object.class, CloudFiles::StorageObject
    assert_equal @object.to_s, 'test_object'
  end
  
  def test_object_creation_with_invalid_name
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5', 'last-modified' => Time.now.to_s}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    container = CloudFiles::Container.new(connection, 'test_container')
    assert_raises SyntaxException do
      @object = CloudFiles::StorageObject.new(container, 'test_object?')
    end
  end
  
  
  def test_public_url_exists
    build_net_http_object(:public => true, :name => 'test object')
    assert_equal @object.public_url, "http://cdn.test.example/test%20object"
  end
  
  def test_public_url_does_not_exist
    build_net_http_object
    assert_equal @object.public_url, nil
  end
  
  def test_data_succeeds
    build_net_http_object(:code => '200', :body => 'This is good data')
    assert_equal @object.data, 'This is good data'
  end
  
  def test_data_with_offset_succeeds
    build_net_http_object(:code => '200', :body => 'Thi')
    assert_equal @object.data(3), 'Thi'
  end
  
  def test_data_fails
    build_net_http_object(:code => '999', :body => 'This is bad data')
    assert_raise(NoSuchObjectException) do
      @object.data
    end
  end
  
  def test_data_stream_succeeds
    build_net_http_object(:code => '200', :body => 'This is good data')
    data = ""
    assert_nothing_raised do
      @object.data_stream { |chunk|
        data += chunk
      }
    end
  end
  
  def test_data_stream_with_offset_succeeds
    build_net_http_object(:code => '200', :body => 'This ')
    data = ""
    assert_nothing_raised do
      @object.data_stream(5) { |chunk|
        data += chunk
      }
    end
  end
  
  # Need to find a way to simulate this properly
  def data_stream_fails
    build_net_http_object(:code => '999', :body => 'This is bad data')
    data = ""
    assert_raise(NoSuchObjectException) do
      @object.data_stream { |chunk|
        data += chunk
      }
    end
  end
  
  def test_set_metadata_succeeds
    CloudFiles::StorageObject.any_instance.stubs(:populate).returns(true)
    build_net_http_object(:code => '202')
    assert_nothing_raised do
      @object.set_metadata({'Foo' =>'bar'})
    end
  end
  
  def test_set_metadata_invalid_object
    build_net_http_object(:code => '404')
    assert_raise(NoSuchObjectException) do
      @object.set_metadata({'Foo' =>'bar'})
    end
  end
  
  def test_set_metadata_fails
    build_net_http_object(:code => '999')
    assert_raise(InvalidResponseException) do
      @object.set_metadata({'Foo' =>'bar'})
    end
  end
  
  def test_read_metadata_succeeds
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5', 'x-object-meta-foo' => 'Bar', 'last-modified' => Time.now.to_s}
    response.stubs(:code).returns('204')
    connection.stubs(:cfreq => response)
    container = CloudFiles::Container.new(connection, 'test_container')
    @object = CloudFiles::StorageObject.new(container, 'test_object')
    assert_equal @object.metadata, {'foo' => 'Bar'}
  end
  
  def test_write_succeeds
    CloudFiles::StorageObject.any_instance.stubs(:populate).returns(true)
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    build_net_http_object(:code => '201')
    assert_nothing_raised do
      @object.write("This is test data")
    end
  end
  
  def test_write_with_make_path
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    response = {'x-container-bytes-used' => '42', 'x-container-object-count' => '5', 'last-modified' => Time.now.to_s}
    response.stubs(:code).returns('204').then.returns('204').then.returns('201').then.returns('204')
    connection.stubs(:cfreq => response)
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    container = CloudFiles::Container.new(connection, 'test_container')
    @object = CloudFiles::StorageObject.new(container, 'path/to/my/test_object', false, true)
    assert_nothing_raised do
      @object.write("This is path test data")
    end
  end
  
  def test_load_from_filename_succeeds
    require 'tempfile'
    out = Tempfile.new('test')
    out.write("This is test data")
    out.close
    CloudFiles::StorageObject.any_instance.stubs(:populate).returns(true)
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    build_net_http_object(:code => '201')
    assert_nothing_raised do
      @object.load_from_filename(out.path)
    end
  end
  
  def test_write_sets_mime_type
    CloudFiles::StorageObject.any_instance.stubs(:populate).returns(true)
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    build_net_http_object(:name => 'myfile.xml', :code => '201')
    assert_nothing_raised do
      @object.write("This is test data")
    end
  end
  
  def test_write_with_no_data_dies
    build_net_http_object
    assert_raise(SyntaxException) do
      @object.write
    end
  end
  
  def test_write_with_invalid_content_length_dies
    build_net_http_object(:code => '412')
    assert_raise(InvalidResponseException) do
      @object.write('Test Data')
    end
  end
  
  def test_write_with_mismatched_md5_dies
    build_net_http_object(:code => '422')
    assert_raise(MisMatchedChecksumException) do
      @object.write('Test Data')
    end
  end
  
  def test_write_with_invalid_response_dies
    build_net_http_object(:code => '999')
    assert_raise(InvalidResponseException) do
      @object.write('Test Data')
    end
  end
  
  private
  
  def build_net_http_object(args={:code => '204' })
    CloudFiles::Container.any_instance.stubs(:populate).returns(true)
    connection = stub(:storagehost => 'test.storage.example', :storagepath => '/dummy/path', :storageport => 443, :storagescheme => 'https', :cdnmgmthost => 'cdm.test.example', :cdnmgmtpath => '/dummy/path', :cdnmgmtport => 443, :cdnmgmtscheme => 'https')
    args[:response] = {} unless args[:response]
    response = {'x-cdn-management-url' => 'http://cdn.example.com/path', 'x-storage-url' => 'http://cdn.example.com/storage', 'authtoken' => 'dummy_token', 'last-modified' => Time.now.to_s}.merge(args[:response])
    response.stubs(:code).returns(args[:code])
    response.stubs(:body).returns args[:body] || nil
    connection.stubs(:cfreq => response)
    container = CloudFiles::Container.new(connection, 'test_container')
    container.stubs(:connection).returns(connection)
    container.stubs(:public?).returns(args[:public] || false)
    container.stubs(:cdn_url).returns('http://cdn.test.example')
    @object = CloudFiles::StorageObject.new(container, args[:name] || 'test_object')
  end
  
  
end