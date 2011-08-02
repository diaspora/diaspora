require 'common'
require 'protocol/02/test_base'

class Protocol::V03::TestBase < Protocol::V02::TestBase
  def test_version
    assert_equal 3, @base.version
  end

  undef test_readlink_should_raise_not_implemented_error
  undef test_symlink_should_raise_not_implemented_error

  def test_readlink_should_send_readlink_packet
    @session.expects(:send_packet).with(FXP_READLINK, :long, 0, :string, "/path/to/link")
    assert_equal 0, @base.readlink("/path/to/link")
  end

  def test_symlink_should_send_symlink_packet
    @session.expects(:send_packet).with(FXP_SYMLINK, :long, 0, :string, "/path/to/link", :string, "/path/to/file")
    assert_equal 0, @base.symlink("/path/to/link", "/path/to/file")
  end

  private

    def driver
      Net::SFTP::Protocol::V03::Base
    end
end
