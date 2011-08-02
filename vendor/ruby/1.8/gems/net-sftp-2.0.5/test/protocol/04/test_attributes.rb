require 'common'

module Etc; end

class Protocol::V04::TestAttributes < Net::SFTP::TestCase
  def setup
    @directory = attributes_factory.new(:type => attributes_factory::T_DIRECTORY)
    @symlink = attributes_factory.new(:type => attributes_factory::T_SYMLINK)
    @file = attributes_factory.new(:type => attributes_factory::T_REGULAR)
  end

  def test_from_buffer_should_correctly_parse_buffer_and_return_attribute_object
    attributes = attributes_factory.from_buffer(full_buffer)

    assert_equal 9, attributes.type
    assert_equal 1234567890, attributes.size
    assert_equal "jamis", attributes.owner
    assert_equal "users", attributes.group
    assert_equal 0755, attributes.permissions
    assert_equal 1234567890, attributes.atime
    assert_equal 12345, attributes.atime_nseconds
    assert_equal 2345678901, attributes.createtime
    assert_equal 23456, attributes.createtime_nseconds
    assert_equal 3456789012, attributes.mtime
    assert_equal 34567, attributes.mtime_nseconds

    assert_equal 2, attributes.acl.length

    assert_equal 1, attributes.acl.first.type
    assert_equal 2, attributes.acl.first.flag
    assert_equal 3, attributes.acl.first.mask
    assert_equal "foo", attributes.acl.first.who

    assert_equal 4, attributes.acl.last.type
    assert_equal 5, attributes.acl.last.flag
    assert_equal 6, attributes.acl.last.mask
    assert_equal "bar", attributes.acl.last.who
    
    assert_equal "second", attributes.extended["first"]
  end

  def test_from_buffer_should_correctly_parse_buffer_with_attribute_subset_and_return_attribute_object
    buffer = Net::SSH::Buffer.from(:long, 0x4, :byte, 1, :long, 0755)

    attributes = attributes_factory.from_buffer(buffer)

    assert_equal 1, attributes.type
    assert_equal 0755, attributes.permissions

    assert_nil attributes.size
    assert_nil attributes.owner
    assert_nil attributes.group
    assert_nil attributes.atime
    assert_nil attributes.atime_nseconds
    assert_nil attributes.createtime
    assert_nil attributes.createtime_nseconds
    assert_nil attributes.mtime
    assert_nil attributes.mtime_nseconds
    assert_nil attributes.acl
    assert_nil attributes.extended
  end

  def test_attributes_to_s_should_build_binary_representation
    attributes = attributes_factory.new(
      :type => 9,
      :size => 1234567890,
      :owner  => "jamis", :group => "users",
      :permissions => 0755,
      :atime => 1234567890, :atime_nseconds => 12345,
      :createtime => 2345678901, :createtime_nseconds => 23456,
      :mtime => 3456789012, :mtime_nseconds => 34567,
      :acl => [attributes_factory::ACL.new(1,2,3,"foo"),
               attributes_factory::ACL.new(4,5,6,"bar")],
      :extended => { "first" => "second" })

    assert_equal full_buffer.to_s, attributes.to_s
  end

  def test_attributes_to_s_should_build_binary_representation_when_subset_is_present
    attributes = attributes_factory.new(:permissions => 0755)
    assert_equal Net::SSH::Buffer.from(:long, 0x4, :byte, 1, :long, 0755).to_s, attributes.to_s
  end

  def test_attributes_to_s_with_uid_and_gid_should_translate_to_owner_and_group
    attributes = attributes_factory.new(:uid => 100, :gid => 200)
    attributes.expects(:require).with("etc").times(2)
    Etc.expects(:getpwuid).with(100).returns(mock('user', :name => "jamis"))
    Etc.expects(:getgrgid).with(200).returns(mock('group', :name => "sftp"))
    assert_equal Net::SSH::Buffer.from(:long, 0x80, :byte, 1, :string, "jamis", :string, "sftp").to_s, attributes.to_s
  end

  def test_uid_should_translate_from_owner
    attributes = attributes_factory.new(:owner => "jamis")
    attributes.expects(:require).with("etc")
    Etc.expects(:getpwnam).with("jamis").returns(mock('user', :uid => 100))
    assert_equal 100, attributes.uid
  end

  def test_gid_should_translate_from_group
    attributes = attributes_factory.new(:group => "sftp")
    attributes.expects(:require).with("etc")
    Etc.expects(:getgrnam).with("sftp").returns(mock('group', :gid => 200))
    assert_equal 200, attributes.gid
  end

  def test_attributes_without_subsecond_times_should_serialize_without_subsecond_times
    attributes = attributes_factory.new(:atime => 100)
    assert_equal Net::SSH::Buffer.from(:long, 0x8, :byte, 1, :int64, 100).to_s, attributes.to_s
  end

  def test_directory_should_be_true_only_when_type_is_directory
    assert @directory.directory?
    assert !@symlink.directory?
    assert !@file.directory?
  end

  def test_symlink_should_be_true_only_when_type_is_symlink
    assert !@directory.symlink?
    assert @symlink.symlink?
    assert !@file.symlink?
  end

  def test_file_should_be_true_only_when_type_is_file
    assert !@directory.file?
    assert !@symlink.file?
    assert @file.file?
  end

  private

    def full_buffer
      Net::SSH::Buffer.from(:long, 0x800001fd,
        :byte, 9, :int64, 1234567890,
        :string, "jamis", :string, "users",
        :long, 0755,
        :int64, 1234567890, :long, 12345,
        :int64, 2345678901, :long, 23456,
        :int64, 3456789012, :long, 34567,
        :string, raw(:long, 2,
          :long, 1, :long, 2, :long, 3, :string, "foo",
          :long, 4, :long, 5, :long, 6, :string, "bar"),
        :long, 1, :string, "first", :string, "second")
    end

    def attributes_factory
      Net::SFTP::Protocol::V04::Attributes
    end
end