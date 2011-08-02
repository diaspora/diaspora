require 'common'
require 'protocol/04/test_base'

class Protocol::V05::TestBase < Protocol::V04::TestBase
  include Net::SFTP::Constants::OpenFlags
  include Net::SFTP::Constants

  def test_version
    assert_equal 5, @base.version
  end

  undef test_rename_should_ignore_flags_parameter

  def test_rename_should_send_rename_packet
    @session.expects(:send_packet).with(FXP_RENAME, :long, 0, :string, "/old/file", :string, "/new/file", :long, 0)
    assert_equal 0, @base.rename("/old/file", "/new/file")
  end

  def test_rename_with_flags_should_send_rename_packet_with_flags
    @session.expects(:send_packet).with(FXP_RENAME, :long, 0, :string, "/old/file", :string, "/new/file", :long, RenameFlags::ATOMIC)
    assert_equal 0, @base.rename("/old/file", "/new/file", RenameFlags::ATOMIC)
  end

  def test_open_with_numeric_flag_should_accept_IO_constants
    @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
      :string, "/path/to/file",
      :long, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES | ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES,
      :long, FV5::CREATE_NEW,
      :raw, attributes.new.to_s)

    assert_equal 0, @base.open("/path/to/file", IO::RDWR | IO::CREAT | IO::EXCL, {})
  end

  { "r"  => [FV5::OPEN_EXISTING, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES],
    "rb" => [FV5::OPEN_EXISTING, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES],
    "r+" => [FV5::OPEN_EXISTING, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES | ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES],
    "w"  => [FV5::CREATE_TRUNCATE, ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES],
    "w+" => [FV5::CREATE_TRUNCATE, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES | ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES],
    "a"  => [FV5::OPEN_OR_CREATE | FV5::APPEND_DATA, ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES | ACE::Mask::APPEND_DATA],
    "a+" => [FV5::OPEN_OR_CREATE | FV5::APPEND_DATA, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES | ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES | ACE::Mask::APPEND_DATA]
  }.each do |mode_string, (flags, access)|
    define_method("test_open_with_#{mode_string.sub(/\+/, '_plus')}_should_translate_correctly") do
      @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
        :string, "/path/to/file", :long, access, :long, flags, :raw, attributes.new.to_s)

      assert_equal 0, @base.open("/path/to/file", mode_string, {})
    end
  end

  def test_open_with_attributes_converts_hash_to_attribute_packet
    @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
      :string, "/path/to/file", :long, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES,
      :long, FV5::OPEN_EXISTING, :raw, attributes.new(:permissions => 0755).to_s)
    @base.open("/path/to/file", "r", :permissions => 0755)
  end

  private

    def driver
      Net::SFTP::Protocol::V05::Base
    end
end
