require 'common'

class Protocol::TestBase < Net::SFTP::TestCase
  def setup
    @base = Net::SFTP::Protocol::Base.new(stub('session', :logger => nil))
  end

  def test_parse_with_status_packet_should_delegate_to_parse_status_packet
    packet = stub('packet', :type => FXP_STATUS)
    @base.expects(:parse_status_packet).with(packet).returns(:result)
    assert_equal :result, @base.parse(packet)
  end

  def test_parse_with_handle_packet_should_delegate_to_parse_handle_packet
    packet = stub('packet', :type => FXP_HANDLE)
    @base.expects(:parse_handle_packet).with(packet).returns(:result)
    assert_equal :result, @base.parse(packet)
  end

  def test_parse_with_data_packet_should_delegate_to_parse_data_packet
    packet = stub('packet', :type => FXP_DATA)
    @base.expects(:parse_data_packet).with(packet).returns(:result)
    assert_equal :result, @base.parse(packet)
  end

  def test_parse_with_name_packet_should_delegate_to_parse_name_packet
    packet = stub('packet', :type => FXP_NAME)
    @base.expects(:parse_name_packet).with(packet).returns(:result)
    assert_equal :result, @base.parse(packet)
  end

  def test_parse_with_attrs_packet_should_delegate_to_parse_attrs_packet
    packet = stub('packet', :type => FXP_ATTRS)
    @base.expects(:parse_attrs_packet).with(packet).returns(:result)
    assert_equal :result, @base.parse(packet)
  end

  def test_parse_with_unknown_packet_should_raise_exception
    packet = stub('packet', :type => FXP_WRITE)
    assert_raises(NotImplementedError) { @base.parse(packet) }
  end
end