require 'common'
require 'protocol/05/test_base'

class Protocol::V06::TestBase < Protocol::V05::TestBase
  include Net::SFTP::Constants::OpenFlags
  include Net::SFTP::Constants

  def test_version
    assert_equal 6, @base.version
  end

  def test_parse_attrs_packet_should_use_correct_attributes_class
    Net::SFTP::Protocol::V06::Attributes.expects(:from_buffer).with(:packet).returns(:result)
    assert_equal({ :attrs => :result }, @base.parse_attrs_packet(:packet))
  end

  undef test_link_should_raise_not_implemented_error
  undef test_block_should_raise_not_implemented_error
  undef test_unblock_should_raise_not_implemented_error
  undef test_symlink_should_send_symlink_packet

  def test_link_should_send_link_packet
    @session.expects(:send_packet).with(FXP_LINK, :long, 0, :string, "/path/to/link", :string, "/path/to/file", :bool, true)
    assert_equal 0, @base.link("/path/to/link", "/path/to/file", true)
  end

  def test_symlink_should_send_link_packet_as_symlink
    @session.expects(:send_packet).with(FXP_LINK, :long, 0, :string, "/path/to/link", :string, "/path/to/file", :bool, true)
    assert_equal 0, @base.symlink("/path/to/link", "/path/to/file")
  end

  def test_block_should_send_block_packet
    @session.expects(:send_packet).with(FXP_BLOCK, :long, 0, :string, "handle", :int64, 1234, :int64, 4567, :long, 0x40)
    assert_equal 0, @base.block("handle", 1234, 4567, 0x40)
  end

  def test_unblock_should_send_unblock_packet
    @session.expects(:send_packet).with(FXP_UNBLOCK, :long, 0, :string, "handle", :int64, 1234, :int64, 4567)
    assert_equal 0, @base.unblock("handle", 1234, 4567)
  end

  private

    def driver
      Net::SFTP::Protocol::V06::Base
    end

    def attributes
      Net::SFTP::Protocol::V06::Attributes
    end
end
