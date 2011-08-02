require 'common'
require 'protocol/01/test_base'

class Protocol::V02::TestBase < Protocol::V01::TestBase
  def test_version
    assert_equal 2, @base.version
  end

  undef test_rename_should_raise_not_implemented_error

  def test_rename_should_send_rename_packet
    @session.expects(:send_packet).with(FXP_RENAME, :long, 0, :string, "/old/file", :string, "/new/file")
    assert_equal 0, @base.rename("/old/file", "/new/file")
  end

  def test_rename_should_ignore_flags_parameter
    @session.expects(:send_packet).with(FXP_RENAME, :long, 0, :string, "/old/file", :string, "/new/file")
    assert_equal 0, @base.rename("/old/file", "/new/file", 1234)
  end

  private

    def driver
      Net::SFTP::Protocol::V02::Base
    end
end
