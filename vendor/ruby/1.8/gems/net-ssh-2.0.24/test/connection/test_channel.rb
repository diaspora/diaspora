require 'common'
require 'net/ssh/connection/channel'

module Connection

  class TestChannel < Test::Unit::TestCase
    include Net::SSH::Connection::Constants

    def teardown
      connection.test!
    end

    def test_constructor_should_set_defaults
      assert_equal 0x10000, channel.local_maximum_packet_size
      assert_equal 0x20000, channel.local_maximum_window_size
      assert channel.pending_requests.empty?
    end

    def test_channel_properties
      channel[:hello] = "some value"
      assert_equal "some value", channel[:hello]
    end

    def test_exec_should_be_syntactic_sugar_for_a_channel_request
      channel.expects(:send_channel_request).with("exec", :string, "ls").yields
      found_block = false
      channel.exec("ls") { found_block = true }
      assert found_block, "expected block to be passed to send_channel_request"
    end

    def test_subsystem_should_be_syntactic_sugar_for_a_channel_request
      channel.expects(:send_channel_request).with("subsystem", :string, "sftp").yields
      found_block = false
      channel.subsystem("sftp") { found_block = true }
      assert found_block, "expected block to be passed to send_channel_request"
    end

    def test_request_pty_with_invalid_option_should_raise_error
      assert_raises(ArgumentError) do
        channel.request_pty(:bogus => "thing")
      end
    end

    def test_request_pty_without_options_should_use_defaults
      channel.expects(:send_channel_request).with("pty-req", :string, "xterm",
        :long, 80, :long, 24, :long, 640, :long, 480, :string, "\0").yields
      found_block = false
      channel.request_pty { found_block = true }
      assert found_block, "expected block to be passed to send_channel_request"
    end

    def test_request_pty_with_options_should_honor_options
      channel.expects(:send_channel_request).with("pty-req", :string, "vanilla",
        :long, 60, :long, 15, :long, 400, :long, 200, :string, "\5\0\0\0\1\0")
      channel.request_pty :term => "vanilla", :chars_wide => 60, :chars_high => 15,
        :pixels_wide => 400, :pixels_high => 200, :modes => { 5 => 1 }
    end

    def test_send_data_should_append_to_channels_output_buffer
      channel.send_data("hello")
      assert_equal "hello", channel.output.to_s
      channel.send_data("world")
      assert_equal "helloworld", channel.output.to_s
    end

    def test_close_before_channel_has_been_confirmed_should_do_nothing
      assert !channel.closing?
      channel.close
      assert !channel.closing?
    end

    def test_close_should_set_closing_and_send_message
      channel.do_open_confirmation(0, 100, 100)
      assert !channel.closing?

      connection.expect { |t,packet| assert_equal CHANNEL_CLOSE, packet.type }
      channel.close

      assert channel.closing?
    end

    def test_close_while_closing_should_do_nothing
      test_close_should_set_closing_and_send_message
      assert_nothing_raised { channel.close }
    end

    def test_process_when_process_callback_is_not_set_should_just_enqueue_data
      channel.expects(:enqueue_pending_output)
      channel.process
    end

    def test_process_when_process_callback_is_set_should_yield_self_before_enqueuing_data
      channel.expects(:enqueue_pending_output).never
      channel.on_process { |ch| ch.expects(:enqueue_pending_output).once }
      channel.process
    end

    def test_enqueue_pending_output_should_have_no_effect_if_channel_has_not_been_confirmed
      channel.send_data("hello")
      assert_nothing_raised { channel.enqueue_pending_output }
    end

    def test_enqueue_pending_output_should_have_no_effect_if_there_is_no_output
      channel.do_open_confirmation(0, 100, 100)
      assert_nothing_raised { channel.enqueue_pending_output }
    end

    def test_enqueue_pending_output_should_not_enqueue_more_than_output_length
      channel.do_open_confirmation(0, 100, 100)
      channel.send_data("hello world")

      connection.expect do |t,packet|
        assert_equal CHANNEL_DATA, packet.type
        assert_equal 0, packet[:local_id]
        assert_equal 11, packet[:data].length
      end

      channel.enqueue_pending_output
    end

    def test_enqueue_pending_output_should_not_enqueue_more_than_max_packet_length_at_once
      channel.do_open_confirmation(0, 100, 8)
      channel.send_data("hello world")

      connection.expect do |t,packet|
        assert_equal CHANNEL_DATA, packet.type
        assert_equal 0, packet[:local_id]
        assert_equal "hello wo", packet[:data]
        
        t.expect do |t2,packet2|
          assert_equal CHANNEL_DATA, packet2.type
          assert_equal 0, packet2[:local_id]
          assert_equal "rld", packet2[:data]
        end
      end

      channel.enqueue_pending_output
    end

    def test_enqueue_pending_output_should_not_enqueue_more_than_max_window_size
      channel.do_open_confirmation(0, 8, 100)
      channel.send_data("hello world")

      connection.expect do |t,packet|
        assert_equal CHANNEL_DATA, packet.type
        assert_equal 0, packet[:local_id]
        assert_equal "hello wo", packet[:data]
      end

      channel.enqueue_pending_output
    end

    def test_on_data_with_block_should_set_callback
      flag = false
      channel.on_data { flag = !flag }
      channel.do_data("")
      assert(flag, "callback should have been invoked")
      channel.on_data
      channel.do_data("")
      assert(flag, "callback should have been removed")
    end

    def test_on_extended_data_with_block_should_set_callback
      flag = false
      channel.on_extended_data { flag = !flag }
      channel.do_extended_data(0, "")
      assert(flag, "callback should have been invoked")
      channel.on_extended_data
      channel.do_extended_data(0, "")
      assert(flag, "callback should have been removed")
    end

    def test_on_process_with_block_should_set_callback
      flag = false
      channel.on_process { flag = !flag }
      channel.process
      assert(flag, "callback should have been invoked")
      channel.on_process
      channel.process
      assert(flag, "callback should have been removed")
    end

    def test_on_close_with_block_should_set_callback
      flag = false
      channel.on_close { flag = !flag }
      channel.do_close
      assert(flag, "callback should have been invoked")
      channel.on_close
      channel.do_close
      assert(flag, "callback should have been removed")
    end

    def test_on_eof_with_block_should_set_callback
      flag = false
      channel.on_eof { flag = !flag }
      channel.do_eof
      assert(flag, "callback should have been invoked")
      channel.on_eof
      channel.do_eof
      assert(flag, "callback should have been removed")
    end

    def test_do_request_for_unhandled_request_should_do_nothing_if_not_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      assert_nothing_raised { channel.do_request "exit-status", false, nil }
    end

    def test_do_request_for_unhandled_request_should_send_CHANNEL_FAILURE_if_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      connection.expect { |t,packet| assert_equal CHANNEL_FAILURE, packet.type }
      channel.do_request "keepalive@openssh.com", true, nil
    end

    def test_do_request_for_handled_request_should_invoke_callback_and_do_nothing_if_returns_true_and_not_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      flag = false
      channel.on_request("exit-status") { flag = true; true }
      assert_nothing_raised { channel.do_request "exit-status", false, nil }
      assert flag, "callback should have been invoked"
    end

    def test_do_request_for_handled_request_should_invoke_callback_and_do_nothing_if_fails_and_not_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      flag = false
      channel.on_request("exit-status") { flag = true; raise Net::SSH::ChannelRequestFailed }
      assert_nothing_raised { channel.do_request "exit-status", false, nil }
      assert flag, "callback should have been invoked"
    end

    def test_do_request_for_handled_request_should_invoke_callback_and_send_CHANNEL_SUCCESS_if_returns_true_and_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      flag = false
      channel.on_request("exit-status") { flag = true; true }
      connection.expect { |t,p| assert_equal CHANNEL_SUCCESS, p.type }
      assert_nothing_raised { channel.do_request "exit-status", true, nil }
      assert flag, "callback should have been invoked"
    end

    def test_do_request_for_handled_request_should_invoke_callback_and_send_CHANNEL_FAILURE_if_returns_false_and_wants_reply
      channel.do_open_confirmation(0, 100, 100)
      flag = false
      channel.on_request("exit-status") { flag = true; raise Net::SSH::ChannelRequestFailed }
      connection.expect { |t,p| assert_equal CHANNEL_FAILURE, p.type }
      assert_nothing_raised { channel.do_request "exit-status", true, nil }
      assert flag, "callback should have been invoked"
    end

    def test_send_channel_request_without_callback_should_not_want_reply
      channel.do_open_confirmation(0, 100, 100)
      connection.expect do |t,p|
        assert_equal CHANNEL_REQUEST, p.type
        assert_equal 0, p[:local_id]
        assert_equal "exec", p[:request]
        assert_equal false, p[:want_reply]
        assert_equal "ls", p[:request_data].read_string
      end
      channel.send_channel_request("exec", :string, "ls")
      assert channel.pending_requests.empty?
    end

    def test_send_channel_request_with_callback_should_want_reply
      channel.do_open_confirmation(0, 100, 100)
      connection.expect do |t,p|
        assert_equal CHANNEL_REQUEST, p.type
        assert_equal 0, p[:local_id]
        assert_equal "exec", p[:request]
        assert_equal true, p[:want_reply]
        assert_equal "ls", p[:request_data].read_string
      end
      callback = Proc.new {}
      channel.send_channel_request("exec", :string, "ls", &callback)
      assert_equal [callback], channel.pending_requests
    end

    def test_do_open_confirmation_should_set_remote_parameters
      channel.do_open_confirmation(1, 2, 3)
      assert_equal 1, channel.remote_id
      assert_equal 2, channel.remote_window_size
      assert_equal 2, channel.remote_maximum_window_size
      assert_equal 3, channel.remote_maximum_packet_size
    end

    def test_do_open_confirmation_should_call_open_confirmation_callback
      flag = false
      channel { flag = true }
      assert !flag, "callback should not have been invoked yet"
      channel.do_open_confirmation(1,2,3)
      assert flag, "callback should have been invoked"
    end

    def test_do_open_confirmation_with_session_channel_should_invoke_agent_forwarding_if_agent_forwarding_requested
      connection :forward_agent => true
      forward = mock("forward")
      forward.expects(:agent).with(channel)
      connection.expects(:forward).returns(forward)
      channel.do_open_confirmation(1,2,3)
    end

    def test_do_open_confirmation_with_non_session_channel_should_not_invoke_agent_forwarding_even_if_agent_forwarding_requested
      connection :forward_agent => true
      channel :type => "direct-tcpip"
      connection.expects(:forward).never
      channel.do_open_confirmation(1,2,3)
    end

    def test_do_window_adjust_should_adjust_remote_window_size_by_the_given_amount
      channel.do_open_confirmation(0, 1000, 1000)
      assert_equal 1000, channel.remote_window_size
      assert_equal 1000, channel.remote_maximum_window_size
      channel.do_window_adjust(500)
      assert_equal 1500, channel.remote_window_size
      assert_equal 1500, channel.remote_maximum_window_size
    end

    def test_do_data_should_update_local_window_size
      assert_equal 0x20000, channel.local_maximum_window_size
      assert_equal 0x20000, channel.local_window_size
      channel.do_data("here is some data")
      assert_equal 0x20000, channel.local_maximum_window_size
      assert_equal 0x1FFEF, channel.local_window_size
    end

    def test_do_extended_data_should_update_local_window_size
      assert_equal 0x20000, channel.local_maximum_window_size
      assert_equal 0x20000, channel.local_window_size
      channel.do_extended_data(1, "here is some data")
      assert_equal 0x20000, channel.local_maximum_window_size
      assert_equal 0x1FFEF, channel.local_window_size
    end

    def test_do_data_when_local_window_size_drops_below_threshold_should_trigger_WINDOW_ADJUST_message
      channel.do_open_confirmation(0, 1000, 1000)
      assert_equal 0x20000, channel.local_maximum_window_size
      assert_equal 0x20000, channel.local_window_size

      connection.expect do |t,p|
        assert_equal CHANNEL_WINDOW_ADJUST, p.type
        assert_equal 0, p[:local_id]
        assert_equal 0x20000, p[:extra_bytes]
      end

      channel.do_data("." * 0x10001)
      assert_equal 0x40000, channel.local_maximum_window_size
      assert_equal 0x2FFFF, channel.local_window_size
    end

    def test_do_failure_should_grab_next_pending_request_and_call_it
      result = nil
      channel.pending_requests << Proc.new { |*args| result = args }
      channel.do_failure
      assert_equal [channel, false], result
      assert channel.pending_requests.empty?
    end

    def test_do_success_should_grab_next_pending_request_and_call_it
      result = nil
      channel.pending_requests << Proc.new { |*args| result = args }
      channel.do_success
      assert_equal [channel, true], result
      assert channel.pending_requests.empty?
    end

    def test_active_should_be_true_when_channel_appears_in_channel_list
      connection.channels[channel.local_id] = channel
      assert channel.active?
    end

    def test_active_should_be_false_when_channel_is_not_in_channel_list
      assert !channel.active?
    end

    def test_wait_should_block_while_channel_is_active?
      channel.expects(:active?).times(3).returns(true,true,false)
      channel.wait
    end

    def test_eof_bang_should_send_eof_to_server
      channel.do_open_confirmation(0, 1000, 1000)
      connection.expect { |t,p| assert_equal CHANNEL_EOF, p.type }
      channel.eof!
      channel.process
    end

    def test_eof_bang_should_not_send_eof_if_eof_was_already_declared
      channel.do_open_confirmation(0, 1000, 1000)
      connection.expect { |t,p| assert_equal CHANNEL_EOF, p.type }
      channel.eof!
      assert_nothing_raised { channel.eof! }
      channel.process
    end

    def test_eof_q_should_return_true_if_eof_declared
      channel.do_open_confirmation(0, 1000, 1000)
      connection.expect { |t,p| assert_equal CHANNEL_EOF, p.type }

      assert !channel.eof?
      channel.eof!
      assert channel.eof?
      channel.process
    end

    def test_send_data_should_raise_exception_if_eof_declared
      channel.do_open_confirmation(0, 1000, 1000)
      connection.expect { |t,p| assert_equal CHANNEL_EOF, p.type }
      channel.eof!
      channel.process
      assert_raises(EOFError) { channel.send_data("die! die! die!") }
    end

    def test_data_should_precede_eof
      channel.do_open_confirmation(0, 1000, 1000)
      connection.expect do |t,p|
        assert_equal CHANNEL_DATA, p.type
        connection.expect { |t,p| assert_equal CHANNEL_EOF, p.type }
      end
      channel.send_data "foo"
      channel.eof!
      channel.process
   end

    private

      class MockConnection
        attr_reader :logger
        attr_reader :options
        attr_reader :channels

        def initialize(options={})
          @expectation = nil
          @options = options
          @channels = {}
        end

        def expect(&block)
          @expectation = block
        end

        def send_message(msg)
          raise "#{msg.to_s.inspect} recieved but no message was expected" unless @expectation
          packet = Net::SSH::Packet.new(msg.to_s)
          callback, @expectation = @expectation, nil
          callback.call(self, packet)
        end

        alias loop_forever loop
        def loop(&block)
          loop_forever { break unless block.call }
        end

        def test!
          raise "expected a packet but none were sent" if @expectation
        end
      end

      def connection(options={})
        @connection ||= MockConnection.new(options)
      end

      def channel(options={}, &block)
        @channel ||= Net::SSH::Connection::Channel.new(connection(options),
          options[:type] || "session",
          options[:local_id] || 0,
          &block)
      end
  end

end
