require 'common'

class ProtocolTest < Net::SFTP::TestCase
  1.upto(6) do |version|
    define_method("test_load_version_#{version}_should_return_v#{version}_driver") do
      session = stub('session', :logger => nil)
      driver = Net::SFTP::Protocol.load(session, version)
      assert_instance_of Net::SFTP::Protocol.const_get("V%02d" % version)::Base, driver
    end
  end

  def test_load_version_7_should_be_unsupported
    assert_raises(NotImplementedError) do
      Net::SFTP::Protocol.load(stub('session'), 7)
    end
  end
end