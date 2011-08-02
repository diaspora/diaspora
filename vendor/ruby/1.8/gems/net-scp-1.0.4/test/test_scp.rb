require 'common'

class TestSCP < Net::SCP::TestCase
  def test_start_without_block_should_return_scp_instance
    ssh = stub('session', :logger => nil)
    Net::SSH.expects(:start).
      with("remote.host", "username", :password => "foo").
      returns(ssh)

    ssh.expects(:close).never
    scp = Net::SCP.start("remote.host", "username", :password => "foo")
    assert_instance_of Net::SCP, scp
    assert_equal ssh, scp.session
  end

  def test_start_with_block_should_yield_scp_and_close_ssh_session
    ssh = stub('session', :logger => nil)
    Net::SSH.expects(:start).
      with("remote.host", "username", :password => "foo").
      returns(ssh)

    ssh.expects(:loop)
    ssh.expects(:close)

    yielded = false
    Net::SCP.start("remote.host", "username", :password => "foo") do |scp|
      yielded = true
      assert_instance_of Net::SCP, scp
      assert_equal ssh, scp.session
    end

    assert yielded
  end

  def test_self_upload_should_instatiate_scp_and_invoke_synchronous_upload
    scp = stub('scp')
    scp.expects(:upload!).with("/path/to/local", "/path/to/remote", :recursive => true)

    Net::SCP.expects(:start).
      with("remote.host", "username", :password => "foo").
      yields(scp)

    Net::SCP.upload!("remote.host", "username", "/path/to/local", "/path/to/remote",
      :ssh => { :password => "foo" }, :recursive => true)
  end

  def test_self_download_should_instatiate_scp_and_invoke_synchronous_download
    scp = stub('scp')
    scp.expects(:download!).with("/path/to/remote", "/path/to/local", :recursive => true).returns(:result)

    Net::SCP.expects(:start).
      with("remote.host", "username", :password => "foo").
      yields(scp)

    result = Net::SCP.download!("remote.host", "username", "/path/to/remote", "/path/to/local",
      :ssh => { :password => "foo" }, :recursive => true)

    assert_equal :result, result
  end
end
