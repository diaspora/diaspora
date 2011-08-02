require 'common'

module Etc; end

class Protocol::V01::TestAttributes < Net::SFTP::TestCase
  def test_from_buffer_should_correctly_parse_buffer_and_return_attribute_object
    attributes = attributes_factory.from_buffer(full_buffer)

    assert_equal 1234567890, attributes.size
    assert_equal 100, attributes.uid
    assert_equal 200, attributes.gid
    assert_equal 0755, attributes.permissions
    assert_equal 1234567890, attributes.atime
    assert_equal 2345678901, attributes.mtime
    assert_equal "second", attributes.extended["first"]
  end

  def test_from_buffer_should_correctly_parse_buffer_with_attribute_subset_and_return_attribute_object
    buffer = Net::SSH::Buffer.from(:long, 0x4, :long, 0755)

    attributes = attributes_factory.from_buffer(buffer)

    assert_equal 0755, attributes.permissions

    assert_nil attributes.size
    assert_nil attributes.uid
    assert_nil attributes.gid
    assert_nil attributes.atime
    assert_nil attributes.mtime
    assert_nil attributes.extended
  end

  def test_attributes_to_s_should_build_binary_representation
    attributes = attributes_factory.new(
      :size => 1234567890,
      :uid  => 100, :gid => 200,
      :permissions => 0755,
      :atime => 1234567890, :mtime => 2345678901,
      :extended => { "first" => "second" })

    assert_equal full_buffer.to_s, attributes.to_s
  end

  def test_attributes_to_s_should_build_binary_representation_when_subset_is_present
    attributes = attributes_factory.new(:permissions => 0755)
    assert_equal Net::SSH::Buffer.from(:long, 0x4, :long, 0755).to_s, attributes.to_s
  end

  def test_attributes_to_s_with_owner_and_group_should_translate_to_uid_and_gid
    attributes = attributes_factory.new(:owner => "jamis", :group => "sftp")
    attributes.expects(:require).with("etc").times(2)
    Etc.expects(:getpwnam).with("jamis").returns(mock('user', :uid => 100))
    Etc.expects(:getgrnam).with("sftp").returns(mock('group', :gid => 200))
    assert_equal Net::SSH::Buffer.from(:long, 0x2, :long, 100, :long, 200).to_s, attributes.to_s
  end

  def test_owner_should_translate_from_uid
    attributes = attributes_factory.new(:uid => 100)
    attributes.expects(:require).with("etc")
    Etc.expects(:getpwuid).with(100).returns(mock('user', :name => "jamis"))
    assert_equal "jamis", attributes.owner
  end

  def test_group_should_translate_from_gid
    attributes = attributes_factory.new(:gid => 200)
    attributes.expects(:require).with("etc")
    Etc.expects(:getgrgid).with(200).returns(mock('group', :name => "sftp"))
    assert_equal "sftp", attributes.group
  end

  def test_type_should_infer_type_from_permissions
    assert_equal af::T_SOCKET,       af.new(:permissions => 0140755).type
    assert_equal af::T_SYMLINK,      af.new(:permissions => 0120755).type
    assert_equal af::T_REGULAR,      af.new(:permissions => 0100755).type
    assert_equal af::T_BLOCK_DEVICE, af.new(:permissions =>  060755).type
    assert_equal af::T_DIRECTORY,    af.new(:permissions =>  040755).type
    assert_equal af::T_CHAR_DEVICE,  af.new(:permissions =>  020755).type
    assert_equal af::T_FIFO,         af.new(:permissions =>  010755).type
    assert_equal af::T_UNKNOWN,      af.new(:permissions =>    0755).type
    assert_equal af::T_UNKNOWN,      af.new.type
  end

  private

    def full_buffer
      Net::SSH::Buffer.from(:long, 0x8000000f,
        :int64, 1234567890, :long, 100, :long, 200,
        :long, 0755, :long, 1234567890, :long, 2345678901,
        :long, 1, :string, "first", :string, "second")
    end

    def attributes_factory
      Net::SFTP::Protocol::V01::Attributes
    end

    alias af attributes_factory
end