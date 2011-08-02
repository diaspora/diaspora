require 'common'

class PacketTest < Net::SFTP::TestCase
  def test_packet_should_auto_read_type_byte
    packet = Net::SFTP::Packet.new("\001rest-of-packet-here")
    assert_equal 1, packet.type
    assert_equal "rest-of-packet-here", packet.content[packet.position..-1]
  end
end