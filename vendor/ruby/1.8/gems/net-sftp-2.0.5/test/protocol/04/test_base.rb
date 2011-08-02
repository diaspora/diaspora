require 'common'
require 'protocol/03/test_base'

class Protocol::V04::TestBase < Protocol::V03::TestBase
  def test_version
    assert_equal 4, @base.version
  end

  def test_parse_attrs_packet_should_use_correct_attributes_class
    Net::SFTP::Protocol::V04::Attributes.expects(:from_buffer).with(:packet).returns(:result)
    assert_equal({ :attrs => :result }, @base.parse_attrs_packet(:packet))
  end

  def test_parse_name_packet_should_use_correct_name_class
    packet = Net::SSH::Buffer.from(:long, 2,
      :string, "name1", :long, 0x4, :byte, 1, :long, 0755,
      :string, "name2", :long, 0x4, :byte, 1, :long, 0550)
    names = @base.parse_name_packet(packet)[:names]

    assert_not_nil names
    assert_equal 2, names.length
    assert_instance_of Net::SFTP::Protocol::V04::Name, names.first

    assert_equal "name1", names.first.name
    assert_equal 0755, names.first.attributes.permissions

    assert_equal "name2", names.last.name
    assert_equal 0550, names.last.attributes.permissions
  end

  undef test_fstat_should_ignore_flags_parameter
  undef test_lstat_should_ignore_flags_parameter
  undef test_stat_should_ignore_flags_parameter

  def test_lstat_should_send_lstat_packet
    @session.expects(:send_packet).with(FXP_LSTAT, :long, 0, :string, "/path/to/file", :long, 0x800001fd)
    assert_equal 0, @base.lstat("/path/to/file")
  end

  def test_lstat_with_custom_flags_should_send_lstat_packet_with_given_flags
    @session.expects(:send_packet).with(FXP_LSTAT, :long, 0, :string, "/path/to/file", :long, 1234)
    assert_equal 0, @base.lstat("/path/to/file", 1234)
  end

  def test_fstat_should_send_fstat_packet
    @session.expects(:send_packet).with(FXP_FSTAT, :long, 0, :string, "handle", :long, 0x800001fd)
    assert_equal 0, @base.fstat("handle")
  end

  def test_fstat_with_custom_flags_should_send_fstat_packet_with_given_flags
    @session.expects(:send_packet).with(FXP_FSTAT, :long, 0, :string, "handle", :long, 1234)
    assert_equal 0, @base.fstat("handle", 1234)
  end

  def test_stat_should_send_stat_packet
    @session.expects(:send_packet).with(FXP_STAT, :long, 0, :string, "/path/to/file", :long, 0x800001fd)
    assert_equal 0, @base.stat("/path/to/file")
  end

  def test_stat_with_custom_flags_should_send_stat_packet_with_given_flags
    @session.expects(:send_packet).with(FXP_STAT, :long, 0, :string, "/path/to/file", :long, 1234)
    assert_equal 0, @base.stat("/path/to/file", 1234)
  end

  private

    def driver
      Net::SFTP::Protocol::V04::Base
    end

    def attributes
      Net::SFTP::Protocol::V04::Attributes
    end
end
