require 'common'
require 'net/ssh/authentication/key_manager'

module Authentication

  class TestKeyManager < Test::Unit::TestCase
    def test_key_files_and_known_identities_are_empty_by_default
      assert manager.key_files.empty?
      assert manager.known_identities.empty?
    end

    def test_assume_agent_is_available_by_default
      assert manager.use_agent?
    end

    def test_add_ensures_list_is_unique
      manager.add "/first"
      manager.add "/second"
      manager.add "/third"
      manager.add "/second"
      assert_equal %w(/first /second /third), manager.key_files
    end

    def test_use_agent_should_be_set_to_false_if_agent_could_not_be_found
      Net::SSH::Authentication::Agent.expects(:connect).raises(Net::SSH::Authentication::AgentNotAvailable)
      assert manager.use_agent?
      assert_nil manager.agent
      assert !manager.use_agent?
    end

    def test_each_identity_should_load_from_key_files
      manager.stubs(:agent).returns(nil)

      stub_file_key "/first", rsa
      stub_file_key "/second", dsa      

      identities = []
      manager.each_identity { |identity| identities << identity }

      assert_equal 2, identities.length
      assert_equal rsa.to_blob, identities.first.to_blob
      assert_equal dsa.to_blob, identities.last.to_blob
      
      assert_equal({:from => :file, :file => "/first", :key => rsa}, manager.known_identities[rsa])
      assert_equal({:from => :file, :file => "/second", :key => dsa}, manager.known_identities[dsa])
    end

    def test_identities_should_load_from_agent
      manager.stubs(:agent).returns(agent)

      identities = []
      manager.each_identity { |identity| identities << identity }

      assert_equal 2, identities.length
      assert_equal rsa.to_blob, identities.first.to_blob
      assert_equal dsa.to_blob, identities.last.to_blob

      assert_equal({:from => :agent}, manager.known_identities[rsa])
      assert_equal({:from => :agent}, manager.known_identities[dsa])
    end

    def test_sign_with_agent_originated_key_should_request_signature_from_agent
      manager.stubs(:agent).returns(agent)
      manager.each_identity { |identity| } # preload the known_identities
      agent.expects(:sign).with(rsa, "hello, world").returns("abcxyz123")
      assert_equal "abcxyz123", manager.sign(rsa, "hello, world")
    end

    def test_sign_with_file_originated_key_should_load_private_key_and_sign_with_it
      manager.stubs(:agent).returns(nil)
      stub_file_key "/first", rsa(512), true
      rsa.expects(:ssh_do_sign).with("hello, world").returns("abcxyz123")
      manager.each_identity { |identity| } # preload the known_identities
      assert_equal "\0\0\0\assh-rsa\0\0\0\011abcxyz123", manager.sign(rsa, "hello, world")
    end

    private

      def stub_file_key(name, key, also_private=false)
        manager.add(name)
        File.expects(:readable?).with(name).returns(true)
        File.expects(:readable?).with(name + ".pub").returns(false)
        Net::SSH::KeyFactory.expects(:load_private_key).with(name, nil).returns(key).at_least_once
        key.expects(:public_key).returns(key)
      end

      def rsa(size=512)
        @rsa ||= OpenSSL::PKey::RSA.new(size)
      end

      def dsa
        @dsa ||= OpenSSL::PKey::DSA.new(512)
      end

      def agent
        @agent ||= stub("agent", :identities => [rsa, dsa])
      end

      def manager
        @manager ||= Net::SSH::Authentication::KeyManager.new(nil)
      end

  end

end
