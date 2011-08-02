require 'common'
require 'net/ssh/authentication/agent'

module Authentication

  class TestAgent < Test::Unit::TestCase

    SSH2_AGENT_REQUEST_VERSION    = 1
    SSH2_AGENT_REQUEST_IDENTITIES = 11
    SSH2_AGENT_IDENTITIES_ANSWER  = 12
    SSH2_AGENT_SIGN_REQUEST       = 13
    SSH2_AGENT_SIGN_RESPONSE      = 14
    SSH2_AGENT_FAILURE            = 30
    SSH2_AGENT_VERSION_RESPONSE   = 103

    SSH_COM_AGENT2_FAILURE        = 102

    SSH_AGENT_REQUEST_RSA_IDENTITIES = 1
    SSH_AGENT_RSA_IDENTITIES_ANSWER  = 2
    SSH_AGENT_FAILURE                = 5

    def setup
      @original, ENV['SSH_AUTH_SOCK'] = ENV['SSH_AUTH_SOCK'], "/path/to/ssh.agent.sock"
    end

    def teardown
      ENV['SSH_AUTH_SOCK'] = @original
    end

    def test_connect_should_use_agent_factory_to_determine_connection_type
      factory.expects(:open).with("/path/to/ssh.agent.sock").returns(socket)
      agent(false).connect!
    end

    def test_connect_should_raise_error_if_connection_could_not_be_established
      factory.expects(:open).raises(SocketError)
      assert_raises(Net::SSH::Authentication::AgentNotAvailable) { agent(false).connect! }
    end

    def test_negotiate_should_raise_error_if_ssh2_agent_response_recieved
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_VERSION, type
        assert_equal Net::SSH::Transport::ServerVersion::PROTO_VERSION, buffer.read_string
        s.return(SSH2_AGENT_VERSION_RESPONSE)
      end
      assert_raises(NotImplementedError) { agent.negotiate! }
    end

    def test_negotiate_should_raise_error_if_response_was_unexpected
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_VERSION, type
        s.return(255)
      end
      assert_raises(Net::SSH::Authentication::AgentError) { agent.negotiate! }
    end

    def test_negotiate_should_be_successful_with_expected_response
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_VERSION, type
        s.return(SSH_AGENT_RSA_IDENTITIES_ANSWER)
      end
      assert_nothing_raised { agent(:connect).negotiate! }
    end

    def test_identities_should_fail_if_SSH_AGENT_FAILURE_recieved
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_IDENTITIES, type
        s.return(SSH_AGENT_FAILURE) 
      end
      assert_raises(Net::SSH::Authentication::AgentError) { agent.identities }
    end

    def test_identities_should_fail_if_SSH2_AGENT_FAILURE_recieved
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_IDENTITIES, type
        s.return(SSH2_AGENT_FAILURE) 
      end
      assert_raises(Net::SSH::Authentication::AgentError) { agent.identities }
    end

    def test_identities_should_fail_if_SSH_COM_AGENT2_FAILURE_recieved
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_IDENTITIES, type
        s.return(SSH_COM_AGENT2_FAILURE) 
      end
      assert_raises(Net::SSH::Authentication::AgentError) { agent.identities }
    end

    def test_identities_should_fail_if_response_is_not_SSH2_AGENT_IDENTITIES_ANSWER
      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_IDENTITIES, type
        s.return(255)
      end
      assert_raises(Net::SSH::Authentication::AgentError) { agent.identities }
    end

    def test_identities_should_augment_identities_with_comment_field
      key1 = key
      key2 = OpenSSL::PKey::DSA.new(512)

      socket.expect do |s, type, buffer|
        assert_equal SSH2_AGENT_REQUEST_IDENTITIES, type
        s.return(SSH2_AGENT_IDENTITIES_ANSWER, :long, 2, :string, Net::SSH::Buffer.from(:key, key1), :string, "My favorite key", :string, Net::SSH::Buffer.from(:key, key2), :string, "Okay, but not the best")
      end

      result = agent.identities
      assert_equal key1.to_blob, result.first.to_blob
      assert_equal key2.to_blob, result.last.to_blob
      assert_equal "My favorite key", result.first.comment
      assert_equal "Okay, but not the best", result.last.comment
    end

    def test_close_should_close_socket
      socket.expects(:close)
      agent.close
    end

    def test_sign_should_fail_if_response_is_SSH_AGENT_FAILURE
      socket.expect { |s,| s.return(SSH_AGENT_FAILURE) }
      assert_raises(Net::SSH::Authentication::AgentError) { agent.sign(key, "hello world") }
    end

    def test_sign_should_fail_if_response_is_SSH2_AGENT_FAILURE
      socket.expect { |s,| s.return(SSH2_AGENT_FAILURE) }
      assert_raises(Net::SSH::Authentication::AgentError) { agent.sign(key, "hello world") }
    end

    def test_sign_should_fail_if_response_is_SSH_COM_AGENT2_FAILURE
      socket.expect { |s,| s.return(SSH_COM_AGENT2_FAILURE) }
      assert_raises(Net::SSH::Authentication::AgentError) { agent.sign(key, "hello world") }
    end

    def test_sign_should_fail_if_response_is_not_SSH2_AGENT_SIGN_RESPONSE
      socket.expect { |s,| s.return(255) }
      assert_raises(Net::SSH::Authentication::AgentError) { agent.sign(key, "hello world") }
    end

    def test_sign_should_return_signed_data_from_agent
      socket.expect do |s,type,buffer|
        assert_equal SSH2_AGENT_SIGN_REQUEST, type
        assert_equal key.to_blob, Net::SSH::Buffer.new(buffer.read_string).read_key.to_blob
        assert_equal "hello world", buffer.read_string
        assert_equal 0, buffer.read_long

        s.return(SSH2_AGENT_SIGN_RESPONSE, :string, "abcxyz123")
      end

      assert_equal "abcxyz123", agent.sign(key, "hello world")
    end

    private

      class MockSocket
        def initialize
          @expectation = nil
          @buffer = Net::SSH::Buffer.new
        end

        def expect(&block)
          @expectation = block
        end

        def return(type, *args)
          data = Net::SSH::Buffer.from(*args)
          @buffer.append([data.length+1, type, data.to_s].pack("NCA*"))
        end

        def send(data, flags)
          raise "got #{data.inspect} but no packet was expected" unless @expectation
          buffer = Net::SSH::Buffer.new(data)
          buffer.read_long # skip the length
          type = buffer.read_byte
          @expectation.call(self, type, buffer)
          @expectation = nil
        end

        def read(length)
          @buffer.read(length)
        end
      end

      def key
        @key ||= OpenSSL::PKey::RSA.new(512)
      end

      def socket
        @socket ||= MockSocket.new
      end

      def factory
        @factory ||= stub("socket factory", :open => socket)
      end

      def agent(auto=:connect)
        @agent ||= begin
          agent = Net::SSH::Authentication::Agent.new
          agent.stubs(:agent_socket_factory).returns(factory)
          agent.connect! if auto == :connect
          agent
        end
      end

  end

end