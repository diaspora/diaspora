require 'common'
require 'net/ssh/transport/packet_stream'

module Transport

  class TestPacketStream < Test::Unit::TestCase
    include Net::SSH::Transport::Constants

    def test_client_name_when_getnameinfo_works
      stream.expects(:getsockname).returns(:sockaddr)
      Socket.expects(:getnameinfo).with(:sockaddr, Socket::NI_NAMEREQD).returns(["net.ssh.test"])
      assert_equal "net.ssh.test", stream.client_name
    end

    def test_client_name_when_getnameinfo_fails_first_and_then_works
      stream.expects(:getsockname).returns(:sockaddr)
      Socket.expects(:getnameinfo).with(:sockaddr, Socket::NI_NAMEREQD).raises(SocketError)
      Socket.expects(:getnameinfo).with(:sockaddr).returns(["1.2.3.4"])
      assert_equal "1.2.3.4", stream.client_name
    end

    def test_client_name_when_getnameinfo_fails_but_gethostbyname_works
      stream.expects(:getsockname).returns(:sockaddr)
      Socket.expects(:getnameinfo).with(:sockaddr, Socket::NI_NAMEREQD).raises(SocketError)
      Socket.expects(:getnameinfo).with(:sockaddr).raises(SocketError)
      Socket.expects(:gethostname).returns(:hostname)
      Socket.expects(:gethostbyname).with(:hostname).returns(["net.ssh.test"])
      assert_equal "net.ssh.test", stream.client_name
    end

    def test_client_name_when_getnameinfo_and_gethostbyname_all_fail
      stream.expects(:getsockname).returns(:sockaddr)
      Socket.expects(:getnameinfo).with(:sockaddr, Socket::NI_NAMEREQD).raises(SocketError)
      Socket.expects(:getnameinfo).with(:sockaddr).raises(SocketError)
      Socket.expects(:gethostname).returns(:hostname)
      Socket.expects(:gethostbyname).with(:hostname).raises(SocketError)
      assert_equal "unknown", stream.client_name
    end

    def test_peer_ip_should_query_socket_for_info_about_peer
      stream.expects(:getpeername).returns(:sockaddr)
      Socket.expects(:getnameinfo).with(:sockaddr, Socket::NI_NUMERICHOST | Socket::NI_NUMERICSERV).returns(["1.2.3.4"])
      assert_equal "1.2.3.4", stream.peer_ip
    end

    def test_available_for_read_should_return_nontrue_when_select_fails
      IO.expects(:select).returns(nil)
      assert !stream.available_for_read?
    end

    def test_available_for_read_should_return_nontrue_when_self_is_not_ready
      IO.expects(:select).with([stream], nil, nil, 0).returns([[],[],[]])
      assert !stream.available_for_read?
    end

    def test_available_for_read_should_return_true_when_self_is_ready
      IO.expects(:select).with([stream], nil, nil, 0).returns([[self],[],[]])
      assert stream.available_for_read?
    end

    def test_cleanup_should_delegate_cleanup_to_client_and_server_states
      stream.client.expects(:cleanup)
      stream.server.expects(:cleanup)
      stream.cleanup
    end

    def test_if_needs_rekey_should_not_yield_if_neither_client_nor_server_states_need_rekey
      stream.if_needs_rekey? { flunk "shouldn't need rekey" }
      assert(true)
    end

    def test_if_needs_rekey_should_yield_and_cleanup_if_client_needs_rekey
      stream.client.stubs(:needs_rekey?).returns(true)
      stream.client.expects(:reset!)
      stream.server.expects(:reset!).never
      rekeyed = false
      stream.if_needs_rekey? { rekeyed = true }
      assert(rekeyed)
    end

    def test_if_needs_rekey_should_yield_and_cleanup_if_server_needs_rekey
      stream.server.stubs(:needs_rekey?).returns(true)
      stream.server.expects(:reset!)
      stream.client.expects(:reset!).never
      rekeyed = false
      stream.if_needs_rekey? { rekeyed = true }
      assert(rekeyed)
    end

    def test_if_needs_rekey_should_yield_and_cleanup_if_both_need_rekey
      stream.server.stubs(:needs_rekey?).returns(true)
      stream.client.stubs(:needs_rekey?).returns(true)
      stream.server.expects(:reset!)
      stream.client.expects(:reset!)
      rekeyed = false
      stream.if_needs_rekey? { rekeyed = true }
      assert(rekeyed)
    end

    def test_next_packet_should_not_block_by_default
      IO.expects(:select).returns(nil)
      assert_nothing_raised do
        timeout(1) { stream.next_packet }
      end
    end

    def test_next_packet_should_return_nil_when_non_blocking_and_not_ready
      IO.expects(:select).returns(nil)
      assert_nil stream.next_packet(:nonblock)
    end

    def test_next_packet_should_return_nil_when_non_blocking_and_partial_read
      IO.expects(:select).returns([[stream]])
      stream.expects(:recv).returns([8].pack("N"))
      assert_nil stream.next_packet(:nonblock)
      assert !stream.read_buffer.empty?
    end

    def test_next_packet_should_return_packet_when_non_blocking_and_full_read
      IO.expects(:select).returns([[stream]])
      stream.expects(:recv).returns(packet)
      packet = stream.next_packet(:nonblock)
      assert_not_nil packet
      assert_equal DEBUG, packet.type
    end

    def test_next_packet_should_eventually_return_packet_when_non_blocking_and_partial_read
      IO.stubs(:select).returns([[stream]])
      stream.stubs(:recv).returns(packet[0,10], packet[10..-1])
      assert_nil stream.next_packet(:nonblock)
      packet = stream.next_packet(:nonblock)
      assert_not_nil packet
      assert_equal DEBUG, packet.type
    end

    def test_next_packet_should_block_when_requested_until_entire_packet_is_available
      IO.stubs(:select).returns([[stream]])
      stream.stubs(:recv).returns(packet[0,10], packet[10,20], packet[20..-1])
      packet = stream.next_packet(:block)
      assert_not_nil packet
      assert_equal DEBUG, packet.type
    end

    def test_next_packet_when_blocking_should_fail_when_fill_could_not_read_any_data
      IO.stubs(:select).returns([[stream]])
      stream.stubs(:recv).returns("")
      assert_raises(Net::SSH::Disconnect) { stream.next_packet(:block) }
    end

    def test_next_packet_fails_with_invalid_argument
      assert_raises(ArgumentError) { stream.next_packet("invalid") }
    end

    def test_send_packet_should_enqueue_and_send_data_immediately
      stream.expects(:send).times(3).with { |a,b| a == stream.write_buffer && b == 0 }.returns(15)
      IO.expects(:select).times(2).returns([[], [stream]])
      stream.send_packet(ssh_packet)
      assert !stream.pending_write?
    end

    def test_enqueue_short_packet_should_ensure_packet_is_at_least_16_bytes_long
      packet = Net::SSH::Buffer.from(:byte, 0)
      stream.enqueue_packet(packet)
      # 12 originally, plus the block-size (8), plus the 4-byte length field
      assert_equal 24, stream.write_buffer.length
    end

    PACKETS = {
      "3des-cbc" => {
        "hmac-md5" => {
          false => "\003\352\031\261k\243\200\204\301\203]!\a\306\217\201\a[^\304\317\322\264\265~\361\017\n\205\272, #[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\317\222v\316\234<\310\377\310\034\346\351\020:\025{\372PDS\246\344\312J\364\301\n\262\r<\037\231Mu\031\240\255\026\362\200A\305\027\341\261\331x\353\0372\3643h`\177\202",
        },
        "hmac-md5-96" => {
          false => "\003\352\031\261k\243\200\204\301\203]!\a\306\217\201\a[^\304\317\322\264\265~\361\017\n\205\272, #[\343\200Sb\377\265\322\003=S",
          :standard => "\317\222v\316\234<\310\377\310\034\346\351\020:\025{\372PDS\246\344\312J\364\301\n\262\r<\037\231Mu\031\240\255\026\362\200A\305\027\341\261\331x\353\0372\3643",
        },
        "hmac-sha1" => {
          false => "\003\352\031\261k\243\200\204\301\203]!\a\306\217\201\a[^\304\317\322\264\265~\361\017\n\205\272, \235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\317\222v\316\234<\310\377\310\034\346\351\020:\025{\372PDS\246\344\312J\364\301\n\262\r<\037\231Mu\031\240\255\026\362\200\345\a{|\0367\355\2735\310'\n\342\250\246\030*1\353\330",
        },
        "hmac-sha1-96" => {
          false => "\003\352\031\261k\243\200\204\301\203]!\a\306\217\201\a[^\304\317\322\264\265~\361\017\n\205\272, \235J\004f\262\3730t\376\273\323n",
          :standard => "\317\222v\316\234<\310\377\310\034\346\351\020:\025{\372PDS\246\344\312J\364\301\n\262\r<\037\231Mu\031\240\255\026\362\200\345\a{|\0367\355\2735\310'\n",
        },
        "none" => {
          false => "\003\352\031\261k\243\200\204\301\203]!\a\306\217\201\a[^\304\317\322\264\265~\361\017\n\205\272, ",
          :standard => "\317\222v\316\234<\310\377\310\034\346\351\020:\025{\372PDS\246\344\312J\364\301\n\262\r<\037\231Mu\031\240\255\026\362\200",
        },
      },
      "aes128-cbc" => {
        "hmac-md5" => {
          false => "\240\016\243k]0\330\253\030\320\334\261(\034E\211\230#\326\374\267\311O\211E(\234\325n\306NY#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\273\367\324\032\3762\334\026\r\246\342\022\016\325\024\270.\273\005\314\036\312\211\261\037A\361\362:W\316\352K\204\216b\2124>A\265g\331\177\233dK\251\337\227`9L\324[bPd\253XY\205\241\310",
        },
        "hmac-md5-96" => {
          false => "\240\016\243k]0\330\253\030\320\334\261(\034E\211\230#\326\374\267\311O\211E(\234\325n\306NY#[\343\200Sb\377\265\322\003=S",
          :standard => "\273\367\324\032\3762\334\026\r\246\342\022\016\325\024\270.\273\005\314\036\312\211\261\037A\361\362:W\316\352K\204\216b\2124>A\265g\331\177\233dK\251\337\227`9L\324[bPd\253X",
        },
        "hmac-sha1" => {
          false => "\240\016\243k]0\330\253\030\320\334\261(\034E\211\230#\326\374\267\311O\211E(\234\325n\306NY\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\273\367\324\032\3762\334\026\r\246\342\022\016\325\024\270.\273\005\314\036\312\211\261\037A\361\362:W\316\352K\204\216b\2124>A\265g\331\177\233dK\251\314\r\224%\316I\370t\251\372]\031\322pH%\267\337r\247",
        },
        "hmac-sha1-96" => {
          false => "\240\016\243k]0\330\253\030\320\334\261(\034E\211\230#\326\374\267\311O\211E(\234\325n\306NY\235J\004f\262\3730t\376\273\323n",
          :standard => "\273\367\324\032\3762\334\026\r\246\342\022\016\325\024\270.\273\005\314\036\312\211\261\037A\361\362:W\316\352K\204\216b\2124>A\265g\331\177\233dK\251\314\r\224%\316I\370t\251\372]\031",
        },
        "none" => {
          false => "\240\016\243k]0\330\253\030\320\334\261(\034E\211\230#\326\374\267\311O\211E(\234\325n\306NY",
          :standard => "\273\367\324\032\3762\334\026\r\246\342\022\016\325\024\270.\273\005\314\036\312\211\261\037A\361\362:W\316\352K\204\216b\2124>A\265g\331\177\233dK\251",
        },
      },
      "aes192-cbc" => {
        "hmac-md5" => {
          false => "P$\377\302\326\262\276\215\206\343&\257#\315>Mp\232P\345o\215\330\213\t\027\300\360\300\037\267\003#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "se\347\230\026\311\212\250yH\241\302n\364:\276\270M=H1\317\222^\362\237D\225N\354:\343\205M\006[\313$U/yZ\330\235\032\307\320D\337\227`9L\324[bPd\253XY\205\241\310",
        },
        "hmac-md5-96" => {
          false => "P$\377\302\326\262\276\215\206\343&\257#\315>Mp\232P\345o\215\330\213\t\027\300\360\300\037\267\003#[\343\200Sb\377\265\322\003=S",
          :standard => "se\347\230\026\311\212\250yH\241\302n\364:\276\270M=H1\317\222^\362\237D\225N\354:\343\205M\006[\313$U/yZ\330\235\032\307\320D\337\227`9L\324[bPd\253X",
        },
        "hmac-sha1" => {
          false => "P$\377\302\326\262\276\215\206\343&\257#\315>Mp\232P\345o\215\330\213\t\027\300\360\300\037\267\003\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "se\347\230\026\311\212\250yH\241\302n\364:\276\270M=H1\317\222^\362\237D\225N\354:\343\205M\006[\313$U/yZ\330\235\032\307\320D\314\r\224%\316I\370t\251\372]\031\322pH%\267\337r\247",
        },
        "hmac-sha1-96" => {
          false => "P$\377\302\326\262\276\215\206\343&\257#\315>Mp\232P\345o\215\330\213\t\027\300\360\300\037\267\003\235J\004f\262\3730t\376\273\323n",
          :standard => "se\347\230\026\311\212\250yH\241\302n\364:\276\270M=H1\317\222^\362\237D\225N\354:\343\205M\006[\313$U/yZ\330\235\032\307\320D\314\r\224%\316I\370t\251\372]\031",
        },
        "none" => {
          false => "P$\377\302\326\262\276\215\206\343&\257#\315>Mp\232P\345o\215\330\213\t\027\300\360\300\037\267\003",
          :standard => "se\347\230\026\311\212\250yH\241\302n\364:\276\270M=H1\317\222^\362\237D\225N\354:\343\205M\006[\313$U/yZ\330\235\032\307\320D",
        },
      },
      "aes256-cbc" => {
        "hmac-md5" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\337\227`9L\324[bPd\253XY\205\241\310",
        },
        "hmac-md5-96" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340#[\343\200Sb\377\265\322\003=S",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\337\227`9L\324[bPd\253X",
        },
        "hmac-sha1" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\314\r\224%\316I\370t\251\372]\031\322pH%\267\337r\247",
        },
        "hmac-sha1-96" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340\235J\004f\262\3730t\376\273\323n",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\314\r\224%\316I\370t\251\372]\031",
        },
        "none" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365",
        },
      },
      "blowfish-cbc" => {
        "hmac-md5" => {
          false => "vT\353\203\247\206L\255e\371\001 6B/\234g\332\371\224l\227\257\346\373E\237C2\212u)#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "U\257\231e\347\274\bh\016X\232h\334\v\005\316e1G$-\367##\256$rW\000\210\335_\360\f\000\205#\370\201\006A\305\027\341\261\331x\353\0372\3643h`\177\202",
        },
        "hmac-md5-96" => {
          false => "vT\353\203\247\206L\255e\371\001 6B/\234g\332\371\224l\227\257\346\373E\237C2\212u)#[\343\200Sb\377\265\322\003=S",
          :standard => "U\257\231e\347\274\bh\016X\232h\334\v\005\316e1G$-\367##\256$rW\000\210\335_\360\f\000\205#\370\201\006A\305\027\341\261\331x\353\0372\3643",
        },
        "hmac-sha1" => {
          false => "vT\353\203\247\206L\255e\371\001 6B/\234g\332\371\224l\227\257\346\373E\237C2\212u)\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "U\257\231e\347\274\bh\016X\232h\334\v\005\316e1G$-\367##\256$rW\000\210\335_\360\f\000\205#\370\201\006\345\a{|\0367\355\2735\310'\n\342\250\246\030*1\353\330",
        },
        "hmac-sha1-96" => {
          false => "vT\353\203\247\206L\255e\371\001 6B/\234g\332\371\224l\227\257\346\373E\237C2\212u)\235J\004f\262\3730t\376\273\323n",
          :standard => "U\257\231e\347\274\bh\016X\232h\334\v\005\316e1G$-\367##\256$rW\000\210\335_\360\f\000\205#\370\201\006\345\a{|\0367\355\2735\310'\n",
        },
        "none" => {
          false => "vT\353\203\247\206L\255e\371\001 6B/\234g\332\371\224l\227\257\346\373E\237C2\212u)",
          :standard => "U\257\231e\347\274\bh\016X\232h\334\v\005\316e1G$-\367##\256$rW\000\210\335_\360\f\000\205#\370\201\006",
        },
      },
      "cast128-cbc" => {
        "hmac-md5" => {
          false => "\361\026\313!\31235|w~\n\261\257\277\e\277b\246b\342\333\eE\021N\345\343m\314\272\315\376#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\375i\253\004\311E\2011)\220$\251A\245\f(\371\263\314\242\353\260\272\367\276\"\031\224$\244\311W\307Oe\224\0017\336\325A\305\027\341\261\331x\353\0372\3643h`\177\202",
        },
        "hmac-md5-96" => {
          false => "\361\026\313!\31235|w~\n\261\257\277\e\277b\246b\342\333\eE\021N\345\343m\314\272\315\376#[\343\200Sb\377\265\322\003=S",
          :standard => "\375i\253\004\311E\2011)\220$\251A\245\f(\371\263\314\242\353\260\272\367\276\"\031\224$\244\311W\307Oe\224\0017\336\325A\305\027\341\261\331x\353\0372\3643",
        },
        "hmac-sha1" => {
          false => "\361\026\313!\31235|w~\n\261\257\277\e\277b\246b\342\333\eE\021N\345\343m\314\272\315\376\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\375i\253\004\311E\2011)\220$\251A\245\f(\371\263\314\242\353\260\272\367\276\"\031\224$\244\311W\307Oe\224\0017\336\325\345\a{|\0367\355\2735\310'\n\342\250\246\030*1\353\330",
        },
        "hmac-sha1-96" => {
          false => "\361\026\313!\31235|w~\n\261\257\277\e\277b\246b\342\333\eE\021N\345\343m\314\272\315\376\235J\004f\262\3730t\376\273\323n",
          :standard => "\375i\253\004\311E\2011)\220$\251A\245\f(\371\263\314\242\353\260\272\367\276\"\031\224$\244\311W\307Oe\224\0017\336\325\345\a{|\0367\355\2735\310'\n",
        },
        "none" => {
          false => "\361\026\313!\31235|w~\n\261\257\277\e\277b\246b\342\333\eE\021N\345\343m\314\272\315\376",
          :standard => "\375i\253\004\311E\2011)\220$\251A\245\f(\371\263\314\242\353\260\272\367\276\"\031\224$\244\311W\307Oe\224\0017\336\325",
        },
      },
      "idea-cbc" => {
        "hmac-md5" => {
          false => "\342\255\202$\273\201\025#\245\2341F\263\005@{\000<\266&s\016\251NH=J\322/\220 H#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "F\3048\360\357\265\215I\021)\a\254/\315%\354M\004\330\006\356\vFr\250K\225\223x\277+Q)\022\327\311K\025\322\317A\305\027\341\261\331x\353\0372\3643h`\177\202",
        },
        "hmac-md5-96" => {
          false => "\342\255\202$\273\201\025#\245\2341F\263\005@{\000<\266&s\016\251NH=J\322/\220 H#[\343\200Sb\377\265\322\003=S",
          :standard => "F\3048\360\357\265\215I\021)\a\254/\315%\354M\004\330\006\356\vFr\250K\225\223x\277+Q)\022\327\311K\025\322\317A\305\027\341\261\331x\353\0372\3643",
        },
        "hmac-sha1" => {
          false => "\342\255\202$\273\201\025#\245\2341F\263\005@{\000<\266&s\016\251NH=J\322/\220 H\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "F\3048\360\357\265\215I\021)\a\254/\315%\354M\004\330\006\356\vFr\250K\225\223x\277+Q)\022\327\311K\025\322\317\345\a{|\0367\355\2735\310'\n\342\250\246\030*1\353\330",
        },
        "hmac-sha1-96" => {
          false => "\342\255\202$\273\201\025#\245\2341F\263\005@{\000<\266&s\016\251NH=J\322/\220 H\235J\004f\262\3730t\376\273\323n",
          :standard => "F\3048\360\357\265\215I\021)\a\254/\315%\354M\004\330\006\356\vFr\250K\225\223x\277+Q)\022\327\311K\025\322\317\345\a{|\0367\355\2735\310'\n",
        },
        "none" => {
          false => "\342\255\202$\273\201\025#\245\2341F\263\005@{\000<\266&s\016\251NH=J\322/\220 H",
          :standard => "F\3048\360\357\265\215I\021)\a\254/\315%\354M\004\330\006\356\vFr\250K\225\223x\277+Q)\022\327\311K\025\322\317",
        },
      },
      "none" => {
        "hmac-md5" => {
          false => "\000\000\000\034\b\004\001\000\000\000\tdebugging\000\000\000\000\b\030CgWO\260\212#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\000\000\000$\tx\234bad``\340LIM*MO\317\314K\ar\030\000\000\000\000\377\377\b\030CgWO\260\212^A\305\027\341\261\331x\353\0372\3643h`\177\202",
        },
        "hmac-md5-96" => {
          false => "\000\000\000\034\b\004\001\000\000\000\tdebugging\000\000\000\000\b\030CgWO\260\212#[\343\200Sb\377\265\322\003=S",
          :standard => "\000\000\000$\tx\234bad``\340LIM*MO\317\314K\ar\030\000\000\000\000\377\377\b\030CgWO\260\212^A\305\027\341\261\331x\353\0372\3643",
        },
        "hmac-sha1" => {
          false => "\000\000\000\034\b\004\001\000\000\000\tdebugging\000\000\000\000\b\030CgWO\260\212\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\000\000\000$\tx\234bad``\340LIM*MO\317\314K\ar\030\000\000\000\000\377\377\b\030CgWO\260\212^\345\a{|\0367\355\2735\310'\n\342\250\246\030*1\353\330",
        },
        "hmac-sha1-96" => {
          false => "\000\000\000\034\b\004\001\000\000\000\tdebugging\000\000\000\000\b\030CgWO\260\212\235J\004f\262\3730t\376\273\323n",
          :standard => "\000\000\000$\tx\234bad``\340LIM*MO\317\314K\ar\030\000\000\000\000\377\377\b\030CgWO\260\212^\345\a{|\0367\355\2735\310'\n",
        },
        "none" => {
          false => "\000\000\000\034\b\004\001\000\000\000\tdebugging\000\000\000\000\b\030CgWO\260\212",
          :standard => "\000\000\000$\tx\234bad``\340LIM*MO\317\314K\ar\030\000\000\000\000\377\377\b\030CgWO\260\212^",
        },
      },
      "rijndael-cbc@lysator.liu.se" => {
        "hmac-md5" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340#[\343\200Sb\377\265\322\003=S\255N\2654",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\337\227`9L\324[bPd\253XY\205\241\310",
        },
        "hmac-md5-96" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340#[\343\200Sb\377\265\322\003=S",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\337\227`9L\324[bPd\253X",
        },
        "hmac-sha1" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340\235J\004f\262\3730t\376\273\323n\260\275\202\223\214\370D\204",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\314\r\224%\316I\370t\251\372]\031\322pH%\267\337r\247",
        },
        "hmac-sha1-96" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340\235J\004f\262\3730t\376\273\323n",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365\314\r\224%\316I\370t\251\372]\031",
        },
        "none" => {
          false => "\266\001oG(\201s\255[\202j\031-\354\353]\022\374\367j2\257\b#\273r\275\341\232\264\255\340",
          :standard => "\251!O/_\253\321\217e\225\202\202W\261p\r\357\357\375\231\264Y,nZ/\366\225G\256\3000\036\223\237\353\265vG\231\215cvY\236%\315\365",
        },
      },
    }

    ciphers = Net::SSH::Transport::CipherFactory::SSH_TO_OSSL.keys
    hmacs = Net::SSH::Transport::HMAC::MAP.keys

    ciphers.each do |cipher_name|
      next unless Net::SSH::Transport::CipherFactory.supported?(cipher_name)
      
      # TODO: How are the expected packets generated?
      if cipher_name =~ /arcfour/
        puts "Skipping packet stream test for #{cipher_name}"
        next 
      end
      
      # JRuby Zlib implementation (1.4 & 1.5) does not have byte-to-byte compatibility with MRI's.
      # skip these 80 or more tests under JRuby.
      if defined?(JRUBY_VERSION)
        puts "Skipping zlib tests for JRuby"
        next
      end

      hmacs.each do |hmac_name|
        [false, :standard].each do |compress|
          cipher_method_name = cipher_name.gsub(/\W/, "_")
          hmac_method_name   = hmac_name.gsub(/\W/, "_")
          
          define_method("test_next_packet_with_#{cipher_method_name}_and_#{hmac_method_name}_and_#{compress}_compression") do
            cipher = Net::SSH::Transport::CipherFactory.get(cipher_name, :key => "ABC", :iv => "abc", :shared => "123", :digester => OpenSSL::Digest::SHA1, :hash => "^&*", :decrypt => true)
            hmac  = Net::SSH::Transport::HMAC.get(hmac_name, "{}|")

            stream.server.set :cipher => cipher, :hmac => hmac, :compression => compress
            stream.stubs(:recv).returns(PACKETS[cipher_name][hmac_name][compress])
            IO.stubs(:select).returns([[stream]])
            packet = stream.next_packet(:nonblock)
            assert_not_nil packet
            assert_equal DEBUG, packet.type
            assert packet[:always_display]
            assert_equal "debugging", packet[:message]
            assert_equal "", packet[:language]
            stream.cleanup
          end

          define_method("test_enqueue_packet_with_#{cipher_method_name}_and_#{hmac_method_name}_and_#{compress}_compression") do
            cipher = Net::SSH::Transport::CipherFactory.get(cipher_name, :key => "ABC", :iv => "abc", :shared => "123", :digester => OpenSSL::Digest::SHA1, :hash => "^&*", :encrypt => true)
            hmac  = Net::SSH::Transport::HMAC.get(hmac_name, "{}|")

            srand(100)
            stream.client.set :cipher => cipher, :hmac => hmac, :compression => compress
            stream.enqueue_packet(ssh_packet)
            assert_equal stream.write_buffer, PACKETS[cipher_name][hmac_name][compress]
            stream.cleanup
          end
        end
      end
    end

    private

      def stream
        @stream ||= begin
          stream = mock("packet_stream")
          stream.extend(Net::SSH::Transport::PacketStream)
          stream
        end
      end

      def ssh_packet
        Net::SSH::Buffer.from(:byte, DEBUG, :bool, true, :string, "debugging", :string, "")
      end

      def packet
        @packet ||= begin
          data = ssh_packet
          length = data.length + 4 + 1 # length + padding length
          padding = stream.server.cipher.block_size - (length % stream.server.cipher.block_size)
          padding += stream.server.cipher.block_size if padding < 4
          Net::SSH::Buffer.from(:long, length + padding - 4, :byte, padding, :raw, data, :raw, "\0" * padding).to_s
        end
      end
  end

end