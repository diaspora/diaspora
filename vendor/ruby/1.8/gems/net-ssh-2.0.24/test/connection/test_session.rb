require 'common'
require 'net/ssh/connection/session'

module Connection

  class TestSession < Test::Unit::TestCase
    include Net::SSH::Connection::Constants

    def test_constructor_should_set_defaults
      assert session.channels.empty?
      assert session.pending_requests.empty?
      assert_equal({ socket => nil }, session.listeners)
    end

    def test_on_open_channel_should_register_block_with_given_channel_type
      flag = false
      session.on_open_channel("testing") { flag = true }
      assert_not_nil session.channel_open_handlers["testing"]
      session.channel_open_handlers["testing"].call
      assert flag, "callback should have been invoked"
    end

    def test_forward_should_create_and_cache_instance_of_forward_service
      assert_instance_of Net::SSH::Service::Forward, session.forward
      assert_equal session.forward.object_id, session.forward.object_id
    end

    def test_listen_to_without_callback_should_add_argument_as_listener
      io = stub("io")
      session.listen_to(io)
      assert session.listeners.key?(io)
      assert_nil session.listeners[io]
    end

    def test_listen_to_should_add_argument_to_listeners_list_if_block_is_given
      io = stub("io", :pending_write? => true)
      flag = false
      session.listen_to(io) { flag = true }
      assert !flag, "callback should not be invoked immediately"
      assert session.listeners.key?(io)
      session.listeners[io].call
      assert flag, "callback should have been invoked"
    end

    def test_stop_listening_to_should_remove_argument_from_listeners
      io = stub("io", :pending_write? => true)

      session.listen_to(io)
      assert session.listeners.key?(io)

      session.stop_listening_to(io)
      assert !session.listeners.key?(io)
    end

    def test_send_message_should_enqueue_message_at_transport_layer
      packet = P(:byte, REQUEST_SUCCESS)
      session.send_message(packet)
      assert_equal packet.to_s, socket.write_buffer
    end

    def test_open_channel_defaults_should_use_session_channel
      flag = false
      channel = session.open_channel { flag = true }
      assert !flag, "callback should not be invoked immediately"
      channel.do_open_confirmation(1,2,3)
      assert flag, "callback should have been invoked"
      assert_equal "session", channel.type
      assert_equal 0, channel.local_id
      assert_equal channel, session.channels[channel.local_id]

      packet = P(:byte, CHANNEL_OPEN, :string, "session", :long, channel.local_id,
        :long, channel.local_maximum_window_size, :long, channel.local_maximum_packet_size)
      assert_equal packet.to_s, socket.write_buffer
    end

    def test_open_channel_with_type_should_use_type
      channel = session.open_channel("direct-tcpip")
      assert_equal "direct-tcpip", channel.type
      packet = P(:byte, CHANNEL_OPEN, :string, "direct-tcpip", :long, channel.local_id,
        :long, channel.local_maximum_window_size, :long, channel.local_maximum_packet_size)
      assert_equal packet.to_s, socket.write_buffer
    end

    def test_open_channel_with_extras_should_append_extras_to_packet
      channel = session.open_channel("direct-tcpip", :string, "other.host", :long, 1234)
      packet = P(:byte, CHANNEL_OPEN, :string, "direct-tcpip", :long, channel.local_id,
        :long, channel.local_maximum_window_size, :long, channel.local_maximum_packet_size,
        :string, "other.host", :long, 1234)
      assert_equal packet.to_s, socket.write_buffer
    end

    def test_send_global_request_without_callback_should_not_expect_reply
      packet = P(:byte, GLOBAL_REQUEST, :string, "testing", :bool, false)
      session.send_global_request("testing")
      assert_equal packet.to_s, socket.write_buffer
      assert session.pending_requests.empty?
    end

    def test_send_global_request_with_callback_should_expect_reply
      packet = P(:byte, GLOBAL_REQUEST, :string, "testing", :bool, true)
      proc = Proc.new {}
      session.send_global_request("testing", &proc)
      assert_equal packet.to_s, socket.write_buffer
      assert_equal [proc], session.pending_requests
    end

    def test_send_global_request_with_extras_should_append_extras_to_packet
      packet = P(:byte, GLOBAL_REQUEST, :string, "testing", :bool, false, :string, "other.host", :long, 1234)
      session.send_global_request("testing", :string, "other.host", :long, 1234)
      assert_equal packet.to_s, socket.write_buffer
    end

    def test_process_should_exit_immediately_if_block_is_false
      session.channels[0] = stub("channel", :closing? => false)
      session.channels[0].expects(:process).never
      process_times(0)
    end

    def test_process_should_exit_after_processing_if_block_is_true_then_false
      session.channels[0] = stub("channel", :closing? => false)
      session.channels[0].expects(:process)
      IO.expects(:select).never
      process_times(2)
    end

    def test_process_should_not_process_channels_that_are_closing
      session.channels[0] = stub("channel", :closing? => true)
      session.channels[0].expects(:process).never
      IO.expects(:select).never
      process_times(2)
    end

    def test_global_request_packets_should_be_silently_handled_if_no_handler_exists_for_them
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, false)
      process_times(2)
      assert transport.queue.empty?
      assert !socket.pending_write?
    end

    def test_global_request_packets_should_be_auto_replied_to_even_if_no_handler_exists
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, true)
      process_times(2)
      assert_equal P(:byte, REQUEST_FAILURE).to_s, socket.write_buffer
    end

    def test_global_request_handler_should_not_trigger_auto_reply_if_no_reply_is_wanted
      flag = false
      session.on_global_request("testing") { flag = true }
      assert !flag, "callback should not be invoked yet"
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, false)
      process_times(2)
      assert transport.queue.empty?
      assert !socket.pending_write?
      assert flag, "callback should have been invoked"
    end

    def test_global_request_handler_returning_true_should_trigger_success_auto_reply
      flag = false
      session.on_global_request("testing") { flag = true }
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, true)
      process_times(2)
      assert_equal P(:byte, REQUEST_SUCCESS).to_s, socket.write_buffer
      assert flag
    end

    def test_global_request_handler_returning_false_should_trigger_failure_auto_reply
      flag = false
      session.on_global_request("testing") { flag = true; false }
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, true)
      process_times(2)
      assert_equal P(:byte, REQUEST_FAILURE).to_s, socket.write_buffer
      assert flag
    end

    def test_global_request_handler_returning_sent_should_not_trigger_auto_reply
      flag = false
      session.on_global_request("testing") { flag = true; :sent }
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, true)
      process_times(2)
      assert !socket.pending_write?
      assert flag
    end

    def test_global_request_handler_returning_other_value_should_raise_error
      session.on_global_request("testing") { "bug" }
      transport.return(GLOBAL_REQUEST, :string, "testing", :bool, true)
      assert_raises(RuntimeError) { process_times(2) }
    end

    def test_request_success_packets_should_invoke_next_pending_request_with_true
      result = nil
      session.pending_requests << Proc.new { |*args| result = args }
      transport.return(REQUEST_SUCCESS)
      process_times(2)
      assert_equal [true, P(:byte, REQUEST_SUCCESS)], result
      assert session.pending_requests.empty?
    end

    def test_request_failure_packets_should_invoke_next_pending_request_with_false
      result = nil
      session.pending_requests << Proc.new { |*args| result = args }
      transport.return(REQUEST_FAILURE)
      process_times(2)
      assert_equal [false, P(:byte, REQUEST_FAILURE)], result
      assert session.pending_requests.empty?
    end

    def test_channel_open_packet_without_corresponding_channel_open_handler_should_result_in_channel_open_failure
      transport.return(CHANNEL_OPEN, :string, "auth-agent", :long, 14, :long, 0x20000, :long, 0x10000)
      process_times(2)
      assert_equal P(:byte, CHANNEL_OPEN_FAILURE, :long, 14, :long, 3, :string, "unknown channel type auth-agent", :string, "").to_s, socket.write_buffer
    end

    def test_channel_open_packet_with_corresponding_handler_should_result_in_channel_open_failure_when_handler_returns_an_error
      transport.return(CHANNEL_OPEN, :string, "auth-agent", :long, 14, :long, 0x20000, :long, 0x10000)
      session.on_open_channel "auth-agent" do |s, ch, p|
        raise Net::SSH::ChannelOpenFailed.new(1234, "we iz in ur channelz!")
      end
      process_times(2)
      assert_equal P(:byte, CHANNEL_OPEN_FAILURE, :long, 14, :long, 1234, :string, "we iz in ur channelz!", :string, "").to_s, socket.write_buffer
    end

    def test_channel_open_packet_with_corresponding_handler_should_result_in_channel_open_confirmation_when_handler_succeeds
      transport.return(CHANNEL_OPEN, :string, "auth-agent", :long, 14, :long, 0x20001, :long, 0x10001)
      result = nil
      session.on_open_channel("auth-agent") { |*args| result = args }
      process_times(2)
      assert_equal P(:byte, CHANNEL_OPEN_CONFIRMATION, :long, 14, :long, 0, :long, 0x20000, :long, 0x10000).to_s, socket.write_buffer
      assert_not_nil(ch = session.channels[0])
      assert_equal [session, ch, P(:byte, CHANNEL_OPEN, :string, "auth-agent", :long, 14, :long, 0x20001, :long, 0x10001)], result
      assert_equal 0, ch.local_id
      assert_equal 14, ch.remote_id
      assert_equal 0x20001, ch.remote_maximum_window_size
      assert_equal 0x10001, ch.remote_maximum_packet_size
      assert_equal 0x20000, ch.local_maximum_window_size
      assert_equal 0x10000, ch.local_maximum_packet_size
      assert_equal "auth-agent", ch.type
    end

    def test_channel_open_failure_should_remove_channel_and_tell_channel_that_open_failed
      session.channels[1] = stub("channel")
      session.channels[1].expects(:do_open_failed).with(1234, "some reason")
      transport.return(CHANNEL_OPEN_FAILURE, :long, 1, :long, 1234, :string, "some reason", :string, "lang tag")
      process_times(2)
      assert session.channels.empty?
    end

    def test_channel_open_confirmation_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_open_confirmation).with(1234, 0x20001, 0x10001)
      transport.return(CHANNEL_OPEN_CONFIRMATION, :long, 14, :long, 1234, :long, 0x20001, :long, 0x10001)
      process_times(2)
    end

    def test_channel_window_adjust_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_window_adjust).with(5000)
      transport.return(CHANNEL_WINDOW_ADJUST, :long, 14, :long, 5000)
      process_times(2)
    end

    def test_channel_request_for_nonexistant_channel_should_be_ignored
      transport.return(CHANNEL_REQUEST, :long, 14, :string, "testing", :bool, false)
      assert_nothing_raised { process_times(2) }
    end

    def test_channel_request_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_request).with("testing", false, Net::SSH::Buffer.new)
      transport.return(CHANNEL_REQUEST, :long, 14, :string, "testing", :bool, false)
      process_times(2)
    end

    def test_channel_data_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_data).with("bring it on down")
      transport.return(CHANNEL_DATA, :long, 14, :string, "bring it on down")
      process_times(2)
    end

    def test_channel_extended_data_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_extended_data).with(1, "bring it on down")
      transport.return(CHANNEL_EXTENDED_DATA, :long, 14, :long, 1, :string, "bring it on down")
      process_times(2)
    end

    def test_channel_eof_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_eof).with()
      transport.return(CHANNEL_EOF, :long, 14)
      process_times(2)
    end

    def test_channel_success_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_success).with()
      transport.return(CHANNEL_SUCCESS, :long, 14)
      process_times(2)
    end

    def test_channel_failure_packet_should_be_routed_to_corresponding_channel
      channel_at(14).expects(:do_failure).with()
      transport.return(CHANNEL_FAILURE, :long, 14)
      process_times(2)
    end

    def test_channel_close_packet_should_be_routed_to_corresponding_channel_and_channel_should_be_closed_and_removed
      channel_at(14).expects(:do_close).with()
      session.channels[14].expects(:close).with()
      transport.return(CHANNEL_CLOSE, :long, 14)
      process_times(2)
      assert session.channels.empty?
    end

    def test_multiple_pending_dispatches_should_be_dispatched_together
      channel_at(14).expects(:do_eof).with()
      session.channels[14].expects(:do_success).with()
      transport.return(CHANNEL_SUCCESS, :long, 14)
      transport.return(CHANNEL_EOF, :long, 14)
      process_times(2)
    end

    def test_writers_without_pending_writes_should_not_be_considered_for_select
      IO.expects(:select).with([socket],[],nil,nil).returns([[],[],[]])
      session.process
    end

    def test_writers_with_pending_writes_should_be_considered_for_select
      socket.enqueue("laksdjflasdkf")
      IO.expects(:select).with([socket],[socket],nil,nil).returns([[],[],[]])
      session.process
    end

    def test_ready_readers_should_be_filled
      socket.expects(:recv).returns("this is some data")
      IO.expects(:select).with([socket],[],nil,nil).returns([[socket],[],[]])
      session.process
      assert_equal [socket], session.listeners.keys
    end

    def test_ready_readers_that_cant_be_filled_should_be_removed
      socket.expects(:recv).returns("")
      socket.expects(:close)
      IO.expects(:select).with([socket],[],nil,nil).returns([[socket],[],[]])
      session.process
      assert session.listeners.empty?
    end

    def test_ready_readers_that_are_registered_with_a_block_should_call_block_instead_of_fill
      io = stub("io", :pending_write? => false)
      flag = false
      session.stop_listening_to(socket) # so that we only have to test the presence of a single IO object
      session.listen_to(io) { flag = true }
      IO.expects(:select).with([io],[],nil,nil).returns([[io],[],[]])
      session.process
      assert flag, "callback should have been invoked"
    end

    def test_ready_writers_should_call_send_pending
      socket.enqueue("laksdjflasdkf")
      socket.expects(:send).with("laksdjflasdkf", 0).returns(13)
      IO.expects(:select).with([socket],[socket],nil,nil).returns([[],[socket],[]])
      session.process
    end

    def test_process_should_call_rekey_as_needed
      transport.expects(:rekey_as_needed)
      IO.expects(:select).with([socket],[],nil,nil).returns([[],[],[]])
      session.process
    end

    def test_loop_should_call_process_until_process_returns_false
      IO.stubs(:select).with([socket],[],nil,nil).returns([[],[],[]])
      session.expects(:process).with(nil).times(4).returns(true,true,true,false).yields
      n = 0
      session.loop { n += 1 }
      assert_equal 4, n
    end

    def test_exec_should_open_channel_and_configure_default_callbacks
      prep_exec("ls", :stdout, "data packet", :stderr, "extended data packet")

      call = :first
      session.exec "ls" do |channel, type, data|
        if call == :first
          assert_equal :stdout, type
          assert_equal "data packet", data
          call = :second
        elsif call == :second
          assert_equal :stderr, type
          assert_equal "extended data packet", data
          call = :third
        else
          flunk "should never get here, call == #{call.inspect}"
        end
      end

      session.loop
      assert_equal :third, call
    end

    def test_exec_without_block_should_use_print_to_display_result
      prep_exec("ls", :stdout, "data packet", :stderr, "extended data packet")
      $stdout.expects(:print).with("data packet")
      $stderr.expects(:print).with("extended data packet")

      session.exec "ls"
      session.loop
    end

    def test_exec_bang_should_block_until_command_finishes
      prep_exec("ls", :stdout, "some data")
      called = false
      session.exec! "ls" do |channel, type, data|
        called = true
        assert_equal :stdout, type
        assert_equal "some data", data
      end
      assert called
    end

    def test_exec_bang_without_block_should_return_data_as_string
      prep_exec("ls", :stdout, "some data")
      assert_equal "some data", session.exec!("ls")
    end

    private

      def prep_exec(command, *data)
        transport.mock_enqueue = true
        transport.expect do |t, p|
          assert_equal CHANNEL_OPEN, p.type
          t.return(CHANNEL_OPEN_CONFIRMATION, :long, p[:remote_id], :long, 0, :long, 0x20000, :long, 0x10000)
          t.expect do |t2, p2|
            assert_equal CHANNEL_REQUEST, p2.type
            assert_equal "exec", p2[:request]
            assert_equal true, p2[:want_reply]
            assert_equal "ls", p2.read_string

            t2.return(CHANNEL_SUCCESS, :long, p[:remote_id])

            0.step(data.length-1, 2) do |index|
              type = data[index]
              datum = data[index+1]

              if type == :stdout
                t2.return(CHANNEL_DATA, :long, p[:remote_id], :string, datum)
              else
                t2.return(CHANNEL_EXTENDED_DATA, :long, p[:remote_id], :long, 1, :string, datum)
              end
            end

            t2.return(CHANNEL_CLOSE, :long, p[:remote_id])
            t2.expect { |t3,p3| assert_equal CHANNEL_CLOSE, p3.type }
          end
        end
      end

      module MockSocket
        # so that we can easily test the contents that were enqueued, without
        # worrying about all the packet stream overhead
        def enqueue_packet(message)
          enqueue(message.to_s)
        end
      end

      def socket
        @socket ||= begin
          socket ||= Object.new
          socket.extend(Net::SSH::Transport::PacketStream)
          socket.extend(MockSocket)
          socket
        end
      end

      def channel_at(local_id)
        session.channels[local_id] = stub("channel", :process => true, :closing? => false)
      end

      def transport(options={})
        @transport ||= MockTransport.new(options.merge(:socket => socket))
      end

      def session(options={})
        @session ||= Net::SSH::Connection::Session.new(transport, options)
      end

      def process_times(n)
        i = 0
        session.process { (i += 1) < n }
      end
  end

end
