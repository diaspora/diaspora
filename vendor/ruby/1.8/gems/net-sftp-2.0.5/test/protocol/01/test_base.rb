require 'common'

# NOTE: these tests assume that the interface to Net::SFTP::Session#send_packet
# will remain constant. If that interface ever changes, these tests will need
# to be updated!

class Protocol::V01::TestBase < Net::SFTP::TestCase
  include Net::SFTP::Constants
  include Net::SFTP::Constants::PacketTypes
  include Net::SFTP::Constants::OpenFlags

  def setup
    @session = stub('session', :logger => nil)
    @base = driver.new(@session)
  end

  def test_version
    assert_equal 1, @base.version
  end

  def test_parse_handle_packet_should_read_string_from_packet_and_return_handle_in_hash
    packet = Net::SSH::Buffer.from(:string, "here is a string")
    assert_equal({ :handle => "here is a string" }, @base.parse_handle_packet(packet))
  end

  def test_parse_status_packet_should_read_long_from_packet_and_return_code_in_hash
    packet = Net::SSH::Buffer.from(:long, 15)
    assert_equal({ :code => 15 }, @base.parse_status_packet(packet))
  end

  def test_parse_data_packet_should_read_string_from_packet_and_return_data_in_hash
    packet = Net::SSH::Buffer.from(:string, "here is a string")
    assert_equal({ :data => "here is a string" }, @base.parse_data_packet(packet))
  end

  def test_parse_attrs_packet_should_use_correct_attributes_class
    Net::SFTP::Protocol::V01::Attributes.expects(:from_buffer).with(:packet).returns(:result)
    assert_equal({ :attrs => :result }, @base.parse_attrs_packet(:packet))
  end

  def test_parse_name_packet_should_use_correct_name_class
    packet = Net::SSH::Buffer.from(:long, 2,
      :string, "name1", :string, "long1", :long, 0x4, :long, 0755,
      :string, "name2", :string, "long2", :long, 0x4, :long, 0550)
    names = @base.parse_name_packet(packet)[:names]

    assert_not_nil names
    assert_equal 2, names.length
    assert_instance_of Net::SFTP::Protocol::V01::Name, names.first

    assert_equal "name1", names.first.name
    assert_equal "long1", names.first.longname
    assert_equal 0755, names.first.attributes.permissions

    assert_equal "name2", names.last.name
    assert_equal "long2", names.last.longname
    assert_equal 0550, names.last.attributes.permissions
  end

  def test_open_with_numeric_flag_should_accept_IO_constants
    @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
      :string, "/path/to/file",
      :long, FV1::READ | FV1::WRITE | FV1::CREAT | FV1::EXCL,
      :raw, attributes.new.to_s)

    assert_equal 0, @base.open("/path/to/file", IO::RDWR | IO::CREAT | IO::EXCL, {})
  end

  { "r"  => FV1::READ,
    "rb" => FV1::READ,
    "r+" => FV1::READ | FV1::WRITE,
    "w"  => FV1::WRITE | FV1::TRUNC | FV1::CREAT,
    "w+" => FV1::WRITE | FV1::READ | FV1::TRUNC | FV1::CREAT,
    "a"  => FV1::APPEND | FV1::WRITE | FV1::CREAT,
    "a+" => FV1::APPEND | FV1::WRITE | FV1::READ | FV1::CREAT
  }.each do |flags, options|
    safe_name = flags.sub(/\+/, "_plus")
    define_method("test_open_with_#{safe_name}_should_translate_correctly") do
      @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
        :string, "/path/to/file", :long, options, :raw, attributes.new.to_s)

      assert_equal 0, @base.open("/path/to/file", flags, {})
    end
  end

  def test_open_with_attributes_converts_hash_to_attribute_packet
    @session.expects(:send_packet).with(FXP_OPEN, :long, 0,
      :string, "/path/to/file", :long, FV1::READ, :raw, attributes.new(:permissions => 0755).to_s)
    @base.open("/path/to/file", "r", :permissions => 0755)
  end

  def test_close_should_send_close_packet
    @session.expects(:send_packet).with(FXP_CLOSE, :long, 0, :string, "handle")
    assert_equal 0, @base.close("handle")
  end

  def test_read_should_send_read_packet
    @session.expects(:send_packet).with(FXP_READ, :long, 0, :string, "handle", :int64, 1234, :long, 5678)
    assert_equal 0, @base.read("handle", 1234, 5678)
  end

  def test_write_should_send_write_packet
    @session.expects(:send_packet).with(FXP_WRITE, :long, 0, :string, "handle", :int64, 1234, :string, "data")
    assert_equal 0, @base.write("handle", 1234, "data")
  end

  def test_lstat_should_send_lstat_packet
    @session.expects(:send_packet).with(FXP_LSTAT, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.lstat("/path/to/file")
  end

  def test_lstat_should_ignore_flags_parameter
    @session.expects(:send_packet).with(FXP_LSTAT, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.lstat("/path/to/file", 12345)
  end

  def test_fstat_should_send_fstat_packet
    @session.expects(:send_packet).with(FXP_FSTAT, :long, 0, :string, "handle")
    assert_equal 0, @base.fstat("handle")
  end

  def test_fstat_should_ignore_flags_parameter
    @session.expects(:send_packet).with(FXP_FSTAT, :long, 0, :string, "handle")
    assert_equal 0, @base.fstat("handle", 12345)
  end

  def test_setstat_should_translate_hash_to_attributes_and_send_setstat_packet
    @session.expects(:send_packet).with(FXP_SETSTAT, :long, 0, :string, "/path/to/file", :raw, attributes.new(:atime => 1, :mtime => 2, :permissions => 0755).to_s)
    assert_equal 0, @base.setstat("/path/to/file", :atime => 1, :mtime => 2, :permissions => 0755)
  end

  def test_fsetstat_should_translate_hash_to_attributes_and_send_fsetstat_packet
    @session.expects(:send_packet).with(FXP_FSETSTAT, :long, 0, :string, "handle", :raw, attributes.new(:atime => 1, :mtime => 2, :permissions => 0755).to_s)
    assert_equal 0, @base.fsetstat("handle", :atime => 1, :mtime => 2, :permissions => 0755)
  end

  def test_opendir_should_send_opendir_packet
    @session.expects(:send_packet).with(FXP_OPENDIR, :long, 0, :string, "/path/to/dir")
    assert_equal 0, @base.opendir("/path/to/dir")
  end

  def test_readdir_should_send_readdir_packet
    @session.expects(:send_packet).with(FXP_READDIR, :long, 0, :string, "handle")
    assert_equal 0, @base.readdir("handle")
  end

  def test_remove_should_send_remove_packet
    @session.expects(:send_packet).with(FXP_REMOVE, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.remove("/path/to/file")
  end

  def test_mkdir_should_translate_hash_to_attributes_and_send_mkdir_packet
    @session.expects(:send_packet).with(FXP_MKDIR, :long, 0, :string, "/path/to/dir", :raw, attributes.new(:atime => 1, :mtime => 2, :permissions => 0755).to_s)
    assert_equal 0, @base.mkdir("/path/to/dir", :atime => 1, :mtime => 2, :permissions => 0755)
  end

  def test_rmdir_should_send_rmdir_packet
    @session.expects(:send_packet).with(FXP_RMDIR, :long, 0, :string, "/path/to/dir")
    assert_equal 0, @base.rmdir("/path/to/dir")
  end

  def test_realpath_should_send_realpath_packet
    @session.expects(:send_packet).with(FXP_REALPATH, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.realpath("/path/to/file")
  end

  def test_stat_should_send_stat_packet
    @session.expects(:send_packet).with(FXP_STAT, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.stat("/path/to/file")
  end

  def test_stat_should_ignore_flags_parameter
    @session.expects(:send_packet).with(FXP_STAT, :long, 0, :string, "/path/to/file")
    assert_equal 0, @base.stat("/path/to/file", 12345)
  end

  def test_rename_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.rename("/path/to/old", "/path/to/new") }
  end

  def test_readlink_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.readlink("/path/to/link") }
  end

  def test_symlink_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.symlink("/path/to/link", "/path/to/file") }
  end

  def test_link_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.link("/path/to/link", "/path/to/file", true) }
  end

  def test_block_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.block("handle", 100, 200, 0) }
  end

  def test_unblock_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { @base.unblock("handle", 100, 200) }
  end

  private

    def driver
      Net::SFTP::Protocol::V01::Base
    end

    def attributes
      Net::SFTP::Protocol::V01::Attributes
    end
end