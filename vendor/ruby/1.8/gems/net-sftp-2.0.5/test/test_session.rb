require "common"

class SessionTest < Net::SFTP::TestCase
  include Net::SFTP::Constants
  include Net::SFTP::Constants::OpenFlags
  include Net::SFTP::Constants::PacketTypes

  (1..6).each do |version|
    define_method("test_server_reporting_version_#{version}_should_cause_version_#{version}_to_be_used") do
      expect_sftp_session :server_version => version
      assert_scripted { sftp.connect! }
      assert_equal version, sftp.protocol.version
    end
  end

  def test_v1_open_read_only_that_succeeds_should_invoke_callback
    expect_open("/path/to/file", "r", nil, :server_version => 1)
    assert_successful_open("/path/to/file")
  end

  def test_v1_open_read_only_that_fails_should_invoke_callback
    expect_open("/path/to/file", "r", nil, :server_version => 1, :fail => 2)

    assert_command_with_callback(:open, "/path/to/file") do |response|
      assert !response.ok?
      assert_equal 2, response.code
    end
  end

  def test_v1_open_write_only_that_succeeds_should_invoke_callback
    expect_open("/path/to/file", "w", nil, :server_version => 1)
    assert_successful_open("/path/to/file", "w")
  end

  def test_v1_open_read_write_that_succeeds_should_invoke_callback
    expect_open("/path/to/file", "rw", nil, :server_version => 1)
    assert_successful_open("/path/to/file", "r+")
  end

  def test_v1_open_append_that_succeeds_should_invoke_callback
    expect_open("/path/to/file", "a", nil, :server_version => 1)
    assert_successful_open("/path/to/file", "a")
  end

  def test_v1_open_with_permissions_should_specify_permissions
    expect_open("/path/to/file", "r", 0765, :server_version => 1)
    assert_successful_open("/path/to/file", "r", :permissions => 0765)
  end

  def test_v4_open_with_permissions_should_specify_permissions
    expect_open("/path/to/file", "r", 0765, :server_version => 4)
    assert_successful_open("/path/to/file", "r", :permissions => 0765)
  end

  def test_v5_open_read_only_shuld_invoke_callback
    expect_open("/path/to/file", "r", 0765, :server_version => 5)
    assert_successful_open("/path/to/file", "r", :permissions => 0765)
  end

  def test_v6_open_with_permissions_should_specify_permissions
    expect_open("/path/to/file", "r", 0765, :server_version => 6)
    assert_successful_open("/path/to/file", "r", :permissions => 0765)
  end

  def test_open_bang_should_block_and_return_handle
    expect_open("/path/to/file", "r", nil)
    handle = assert_synchronous_command(:open!, "/path/to/file", "r")
    assert_equal "handle", handle
  end

  def test_open_bang_should_block_and_raise_exception_on_error
    expect_open("/path/to/file", "r", nil, :fail => 5)
    assert_raises(Net::SFTP::StatusException) do
      assert_synchronous_command(:open!, "/path/to/file", "r")
    end
  end

  def test_close_should_send_close_request_and_invoke_callback
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_CLOSE, :long, 0, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:close, "handle") { |r| assert r.ok? }
  end

  def test_close_bang_should_block_and_return_response
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_CLOSE, :long, 0, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:close!, "handle")
    assert response.ok?
  end

  def test_read_should_send_read_request_and_invoke_callback
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_READ, :long, 0, :string, "handle", :int64, 512123, :long, 1024)
      channel.gets_packet(FXP_DATA, :long, 0, :string, "this is some data!")
    end

    assert_command_with_callback(:read, "handle", 512123, 1024) do |response|
      assert response.ok?
      assert_equal "this is some data!", response[:data]
    end
  end

  def test_read_bang_should_block_and_return_data
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_READ, :long, 0, :string, "handle", :int64, 512123, :long, 1024)
      channel.gets_packet(FXP_DATA, :long, 0, :string, "this is some data!")
    end

    data = assert_synchronous_command(:read!, "handle", 512123, 1024)
    assert_equal "this is some data!", data
  end

  def test_read_bang_should_block_and_return_nil_on_eof
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_READ, :long, 0, :string, "handle", :int64, 512123, :long, 1024)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 1)
    end

    data = assert_synchronous_command(:read!, "handle", 512123, 1024)
    assert_nil data
  end

  def test_write_should_send_write_request_and_invoke_callback
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_WRITE, :long, 0, :string, "handle", :int64, 512123, :string, "this is some data!")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:write, "handle", 512123, "this is some data!") do |response|
      assert response.ok?
    end
  end

  def test_write_bang_should_block_and_return_response
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_WRITE, :long, 0, :string, "handle", :int64, 512123, :string, "this is some data!")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:write!, "handle", 512123, "this is some data!")
    assert response.ok?
  end

  def test_v1_lstat_should_send_lstat_request_and_invoke_callback
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_LSTAT, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    assert_command_with_callback(:lstat, "/path/to/file") do |response|
      assert response.ok?
      assert_equal 123456, response[:attrs].size
      assert_equal 1, response[:attrs].uid
      assert_equal 2, response[:attrs].gid
      assert_equal 0765, response[:attrs].permissions
      assert_equal 123456789, response[:attrs].atime
      assert_equal 234567890, response[:attrs].mtime
    end
  end

  def test_v4_lstat_should_send_default_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_LSTAT, :long, 0, :string, "/path/to/file", :long, 0x800001fd)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:lstat, "/path/to/file")
  end

  def test_v4_lstat_should_honor_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_LSTAT, :long, 0, :string, "/path/to/file", :long, 0x1)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:lstat, "/path/to/file", 0x1)
  end

  def test_lstat_bang_should_block_and_return_attrs
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_LSTAT, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    attrs = assert_synchronous_command(:lstat!, "/path/to/file")

    assert_equal 123456, attrs.size
    assert_equal 1, attrs.uid
    assert_equal 2, attrs.gid
    assert_equal 0765, attrs.permissions
    assert_equal 123456789, attrs.atime
    assert_equal 234567890, attrs.mtime
  end

  def test_v1_fstat_should_send_fstat_request_and_invoke_callback
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_FSTAT, :long, 0, :string, "handle")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    assert_command_with_callback(:fstat, "handle") do |response|
      assert response.ok?
      assert_equal 123456, response[:attrs].size
      assert_equal 1, response[:attrs].uid
      assert_equal 2, response[:attrs].gid
      assert_equal 0765, response[:attrs].permissions
      assert_equal 123456789, response[:attrs].atime
      assert_equal 234567890, response[:attrs].mtime
    end
  end

  def test_v4_fstat_should_send_default_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_FSTAT, :long, 0, :string, "handle", :long, 0x800001fd)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:fstat, "handle")
  end

  def test_v4_fstat_should_honor_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_FSTAT, :long, 0, :string, "handle", :long, 0x1)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:fstat, "handle", 0x1)
  end

  def test_fstat_bang_should_block_and_return_attrs
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_FSTAT, :long, 0, :string, "handle")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    attrs = assert_synchronous_command(:fstat!, "handle")

    assert_equal 123456, attrs.size
    assert_equal 1, attrs.uid
    assert_equal 2, attrs.gid
    assert_equal 0765, attrs.permissions
    assert_equal 123456789, attrs.atime
    assert_equal 234567890, attrs.mtime
  end

  def test_v1_setstat_should_send_v1_attributes
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_SETSTAT, :long, 0, :string, "/path/to/file", :long, 0xc, :long, 0765, :long, 1234567890, :long, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:setstat, "/path/to/file", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
  end

  def test_v4_setstat_should_send_v4_attributes
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_SETSTAT, :long, 0, :string, "/path/to/file", :long, 0x2c, :byte, 1, :long, 0765, :int64, 1234567890, :int64, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:setstat, "/path/to/file", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
  end

  def test_v6_setstat_should_send_v6_attributes
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_SETSTAT, :long, 0, :string, "/path/to/file", :long, 0x102c, :byte, 1, :long, 0765, :int64, 1234567890, :int64, 2345678901, :string, "text/plain")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:setstat, "/path/to/file", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901, :mime_type => "text/plain")
  end

  def test_setstat_bang_should_block_and_return_response
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_SETSTAT, :long, 0, :string, "/path/to/file", :long, 0xc, :long, 0765, :long, 1234567890, :long, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:setstat!, "/path/to/file", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
    assert response.ok?
  end

  def test_v1_fsetstat_should_send_v1_attributes
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_FSETSTAT, :long, 0, :string, "handle", :long, 0xc, :long, 0765, :long, 1234567890, :long, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:fsetstat, "handle", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
  end

  def test_v4_fsetstat_should_send_v4_attributes
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_FSETSTAT, :long, 0, :string, "handle", :long, 0x2c, :byte, 1, :long, 0765, :int64, 1234567890, :int64, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:fsetstat, "handle", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
  end

  def test_v6_fsetstat_should_send_v6_attributes
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_FSETSTAT, :long, 0, :string, "handle", :long, 0x102c, :byte, 1, :long, 0765, :int64, 1234567890, :int64, 2345678901, :string, "text/plain")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:fsetstat, "handle", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901, :mime_type => "text/plain")
  end

  def test_fsetstat_bang_should_block_and_return_response
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_FSETSTAT, :long, 0, :string, "handle", :long, 0xc, :long, 0765, :long, 1234567890, :long, 2345678901)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:fsetstat!, "handle", :permissions => 0765, :atime => 1234567890, :mtime => 2345678901)
    assert response.ok?
  end

  def test_opendir_should_send_opendir_request_and_invoke_callback
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_OPENDIR, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
    end

    assert_command_with_callback(:opendir, "/path/to/dir")
  end

  def test_opendir_bang_should_block_and_return_handle
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_OPENDIR, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
    end

    handle = assert_synchronous_command(:opendir!, "/path/to/dir")
    assert_equal "handle", handle
  end

  def test_readdir_should_send_readdir_request_and_invoke_callback
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_READDIR, :long, 0, :string, "handle")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 1)
    end

    assert_command_with_callback(:readdir, "handle") { |r| assert r.eof? }
  end

  def test_readdir_bang_should_block_and_return_names_array
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_READDIR, :long, 0, :string, "handle")
      channel.gets_packet(FXP_NAME, :long, 0, :long, 2,
        :string, "first", :string, "longfirst", :long, 0x0,
        :string, "next", :string, "longnext", :long, 0x0)
    end

    names = assert_synchronous_command(:readdir!, "handle")
    assert_equal 2, names.length
    assert_equal %w(first next), names.map { |n| n.name }
  end

  def test_remove_should_send_remove_packet
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_REMOVE, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:remove, "/path/to/file")
  end

  def test_remove_bang_should_block_and_return_response
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_REMOVE, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:remove!, "/path/to/file")
    assert response.ok?
  end

  def test_mkdir_should_send_mkdir_packet
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_MKDIR, :long, 0, :string, "/path/to/dir", :long, 0x4, :byte, 1, :long, 0765)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:mkdir, "/path/to/dir", :permissions => 0765)
  end

  def test_mkdir_bang_should_block_and_return_response
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_MKDIR, :long, 0, :string, "/path/to/dir", :long, 0x4, :byte, 1, :long, 0765)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:mkdir!, "/path/to/dir", :permissions => 0765)
    assert response.ok?
  end

  def test_rmdir_should_send_rmdir_packet
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_RMDIR, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:rmdir, "/path/to/dir")
  end

  def test_rmdir_bang_should_block_and_return_response
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_RMDIR, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:rmdir!, "/path/to/dir")
    assert response.ok?
  end

  def test_realpath_should_send_realpath_packet
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_REALPATH, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:realpath, "/path/to/dir")
  end

  def test_realpath_bang_should_block_and_return_names_item
    expect_sftp_session do |channel|
      channel.sends_packet(FXP_REALPATH, :long, 0, :string, "/path/to/dir")
      channel.gets_packet(FXP_NAME, :long, 0, :long, 1, :string, "dir", :long, 0x0, :long, 2)
    end

    name = assert_synchronous_command(:realpath!, "/path/to/dir")
    assert_equal "dir", name.name
  end

  def test_v1_stat_should_send_stat_request_and_invoke_callback
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_STAT, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    assert_command_with_callback(:stat, "/path/to/file") do |response|
      assert response.ok?
      assert_equal 123456, response[:attrs].size
      assert_equal 1, response[:attrs].uid
      assert_equal 2, response[:attrs].gid
      assert_equal 0765, response[:attrs].permissions
      assert_equal 123456789, response[:attrs].atime
      assert_equal 234567890, response[:attrs].mtime
    end
  end

  def test_v4_stat_should_send_default_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_STAT, :long, 0, :string, "/path/to/file", :long, 0x800001fd)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:stat, "/path/to/file")
  end

  def test_v4_stat_should_honor_flags_parameter
    expect_sftp_session :server_version => 4 do |channel|
      channel.sends_packet(FXP_STAT, :long, 0, :string, "/path/to/file", :long, 0x1)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:stat, "/path/to/file", 0x1)
  end

  def test_stat_bang_should_block_and_return_attrs
    expect_sftp_session :server_version => 1 do |channel|
      channel.sends_packet(FXP_STAT, :long, 0, :string, "/path/to/file")
      channel.gets_packet(FXP_ATTRS, :long, 0, :long, 0xF, :int64, 123456, :long, 1, :long, 2, :long, 0765, :long, 123456789, :long, 234567890)
    end

    attrs = assert_synchronous_command(:stat!, "/path/to/file")

    assert_equal 123456, attrs.size
    assert_equal 1, attrs.uid
    assert_equal 2, attrs.gid
    assert_equal 0765, attrs.permissions
    assert_equal 123456789, attrs.atime
    assert_equal 234567890, attrs.mtime
  end

  def test_v1_rename_should_be_unimplemented
    assert_not_implemented 1, :rename, "from", "to"
  end

  def test_v2_rename_should_send_rename_packet
    expect_sftp_session :server_version => 2 do |channel|
      channel.sends_packet(FXP_RENAME, :long, 0, :string, "from", :string, "to")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:rename, "from", "to")
  end

  def test_v5_rename_should_send_rename_packet_and_default_flags
    expect_sftp_session :server_version => 5 do |channel|
      channel.sends_packet(FXP_RENAME, :long, 0, :string, "from", :string, "to", :long, 0)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:rename, "from", "to")
  end

  def test_v5_rename_should_send_rename_packet_and_honor_flags
    expect_sftp_session :server_version => 5 do |channel|
      channel.sends_packet(FXP_RENAME, :long, 0, :string, "from", :string, "to", :long, 1)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:rename, "from", "to", 1)
  end

  def test_rename_bang_should_block_and_return_response
    expect_sftp_session :server_version => 2 do |channel|
      channel.sends_packet(FXP_RENAME, :long, 0, :string, "from", :string, "to")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:rename!, "from", "to")
    assert response.ok?
  end

  def test_v2_readlink_should_be_unimplemented
    assert_not_implemented 2, :readlink, "/path/to/link"
  end

  def test_v3_readlink_should_send_readlink_packet
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_READLINK, :long, 0, :string, "/path/to/link")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 2)
    end

    assert_command_with_callback(:readlink, "/path/to/link")
  end

  def test_readlink_bang_should_block_and_return_name
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_READLINK, :long, 0, :string, "/path/to/link")
      channel.gets_packet(FXP_NAME, :long, 0, :long, 1, :string, "target", :string, "longtarget", :long, 0x0)
    end

    name = assert_synchronous_command(:readlink!, "/path/to/link")
    assert_equal "target", name.name
  end

  def test_v2_symlink_should_be_unimplemented
    assert_not_implemented 2, :symlink, "/path/to/source", "/path/to/link"
  end

  def test_v3_symlink_should_send_symlink_packet
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_SYMLINK, :long, 0, :string, "/path/to/source", :string, "/path/to/link")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:symlink, "/path/to/source", "/path/to/link")
  end

  def test_v6_symlink_should_send_link_packet
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_LINK, :long, 0, :string, "/path/to/link", :string, "/path/to/source", :bool, true)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:symlink, "/path/to/link", "/path/to/source")
  end

  def test_symlink_bang_should_block_and_return_response
    expect_sftp_session :server_version => 3 do |channel|
      channel.sends_packet(FXP_SYMLINK, :long, 0, :string, "/path/to/source", :string, "/path/to/link")
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:symlink!, "/path/to/source", "/path/to/link")
    assert response.ok?
  end

  def test_v5_link_should_be_unimplemented
    assert_not_implemented 5, :link, "/path/to/source", "/path/to/link", true
  end

  def test_v6_link_should_send_link_packet
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_LINK, :long, 0, :string, "/path/to/link", :string, "/path/to/source", :bool, true)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:link, "/path/to/link", "/path/to/source", true)
  end

  def test_link_bang_should_block_and_return_response
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_LINK, :long, 0, :string, "/path/to/link", :string, "/path/to/source", :bool, true)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:link!, "/path/to/link", "/path/to/source", true)
    assert response.ok?
  end

  def test_v5_block_should_be_unimplemented
    assert_not_implemented 5, :block, "handle", 12345, 67890, 0xabcd
  end

  def test_v6_block_should_send_block_packet
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_BLOCK, :long, 0, :string, "handle", :int64, 12345, :int64, 67890, :long, 0xabcd)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:block, "handle", 12345, 67890, 0xabcd)
  end

  def test_block_bang_should_block_and_return_response
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_BLOCK, :long, 0, :string, "handle", :int64, 12345, :int64, 67890, :long, 0xabcd)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:block!, "handle", 12345, 67890, 0xabcd)
    assert response.ok?
  end

  def test_v5_unblock_should_be_unimplemented
    assert_not_implemented 5, :unblock, "handle", 12345, 67890
  end

  def test_v6_unblock_should_send_block_packet
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_UNBLOCK, :long, 0, :string, "handle", :int64, 12345, :int64, 67890)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    assert_command_with_callback(:unblock, "handle", 12345, 67890)
  end

  def test_unblock_bang_should_block_and_return_response
    expect_sftp_session :server_version => 6 do |channel|
      channel.sends_packet(FXP_UNBLOCK, :long, 0, :string, "handle", :int64, 12345, :int64, 67890)
      channel.gets_packet(FXP_STATUS, :long, 0, :long, 0)
    end

    response = assert_synchronous_command(:unblock!, "handle", 12345, 67890)
    assert response.ok?
  end

  private

    def assert_not_implemented(server_version, command, *args)
      expect_sftp_session :server_version => 1
      sftp.connect!
      assert_raises(NotImplementedError) { sftp.send(command, *args) }
    end

    def assert_command_with_callback(command, *args)
      called = false
      assert_scripted_command do
        sftp.send(command, *args) do |response|
          called = true
          yield response if block_given?
        end
      end
      assert called, "expected callback to be invoked, but it wasn't"
    end

    def assert_synchronous_command(command, *args)
      assert_scripted_command do
        sequence = [:start]
        result = sftp.send(command, *args) do |response|
          sequence << :done
          yield response if block_given?
        end
        sequence << :after
        assert_equal [:start, :done, :after], sequence, "expected #{command} to be synchronous"
        return result
      end
    end

    def assert_successful_open(*args)
      assert_command_with_callback(:open, *args) do |response|
        assert response.ok?
        assert_equal "handle", response[:handle]
      end
    end

    def expect_open(path, mode, perms, options={})
      version = options[:server_version] || 6

      fail = options.delete(:fail)

      attrs = [:long, perms ? 0x4 : 0]
      attrs += [:byte, 1] if version >= 4
      attrs += [:long, perms] if perms

      expect_sftp_session(options) do |channel|
        if version >= 5
          flags, access = case mode
            when "r" then 
              [FV5::OPEN_EXISTING, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES]
            when "w" then
              [FV5::CREATE_TRUNCATE, ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES]
            when "rw" then
              [FV5::OPEN_OR_CREATE, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES | ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES]
            when "a" then
              [FV5::OPEN_OR_CREATE | FV5::APPEND_DATA, ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES | ACE::Mask::APPEND_DATA]
            else raise ArgumentError, "unsupported mode #{mode.inspect}"
          end

          channel.sends_packet(FXP_OPEN, :long, 0, :string, path, :long, access, :long, flags, *attrs)
        else
          flags = case mode
            when "r"  then FV1::READ
            when "w"  then FV1::WRITE | FV1::TRUNC | FV1::CREAT
            when "rw" then FV1::WRITE | FV1::READ
            when "a"  then FV1::APPEND | FV1::WRITE | FV1::CREAT
            else raise ArgumentError, "unsupported mode #{mode.inspect}"
          end

          channel.sends_packet(FXP_OPEN, :long, 0, :string, path, :long, flags, *attrs)
        end

        if fail
          channel.gets_packet(FXP_STATUS, :long, 0, :long, fail)
        else
          channel.gets_packet(FXP_HANDLE, :long, 0, :string, "handle")
        end
      end
    end
end
