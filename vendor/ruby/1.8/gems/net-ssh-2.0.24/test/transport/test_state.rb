require 'common'
require 'net/ssh/transport/state'

module Transport

  class TestState < Test::Unit::TestCase

    def setup
      @socket = @state = @deflater = @inflater = nil
    end

    def teardown
      if @deflater
        @deflater.finish if !@deflater.finished?
        @deflater.close
      end

      if @inflater
        @inflater.finish if !@inflater.finished?
        @inflater.close
      end

      state.cleanup
    end

    def test_constructor_should_initialize_all_values
      assert_equal 0, state.sequence_number
      assert_equal 0, state.packets
      assert_equal 0, state.blocks

      assert_nil state.compression
      assert_nil state.compression_level
      assert_nil state.max_packets
      assert_nil state.max_blocks
      assert_nil state.rekey_limit

      assert_equal "identity", state.cipher.name
      assert_instance_of Net::SSH::Transport::HMAC::None, state.hmac
    end

    def test_increment_should_increment_counters
      state.increment(24)
      assert_equal 1, state.sequence_number
      assert_equal 1, state.packets
      assert_equal 3, state.blocks
    end

    def test_reset_should_reset_counters_and_fix_defaults_for_maximums
      state.increment(24)
      state.reset!
      assert_equal 1, state.sequence_number
      assert_equal 0, state.packets
      assert_equal 0, state.blocks
      assert_equal 2147483648, state.max_packets
      assert_equal 134217728, state.max_blocks
    end

    def test_set_should_set_variables_and_reset_counters
      state.expects(:reset!)
      state.set :cipher => :a, :hmac => :b, :compression => :c,
        :compression_level => :d, :max_packets => 500, :max_blocks => 1000,
        :rekey_limit => 1500
      assert_equal :a, state.cipher
      assert_equal :b, state.hmac
      assert_equal :c, state.compression
      assert_equal :d, state.compression_level
      assert_equal 500, state.max_packets
      assert_equal 1000, state.max_blocks
      assert_equal 1500, state.rekey_limit
    end

    def test_set_with_max_packets_should_respect_max_packets_setting
      state.set :max_packets => 500
      assert_equal 500, state.max_packets
    end

    def test_set_with_max_blocks_should_respect_max_blocks_setting
      state.set :max_blocks => 1000
      assert_equal 1000, state.max_blocks
    end

    def test_set_with_rekey_limit_should_include_rekey_limit_in_computation_of_max_blocks
      state.set :rekey_limit => 4000
      assert_equal 500, state.max_blocks
    end

    def test_compressor_defaults_to_default_zlib_compression
      expect = deflater.deflate("hello world")
      assert_equal expect, state.compressor.deflate("hello world")
    end

    def test_compressor_uses_compression_level_when_given
      state.set :compression_level => 1
      expect = deflater(1).deflate("hello world")
      assert_equal expect, state.compressor.deflate("hello world")
    end

    def test_compress_when_no_compression_is_active_returns_text
      assert_equal "hello everybody", state.compress("hello everybody")
    end

    def test_decompress_when_no_compression_is_active_returns_text
      assert_equal "hello everybody", state.decompress("hello everybody")
    end

    def test_compress_when_compression_is_delayed_and_no_auth_hint_is_set_should_return_text
      state.set :compression => :delayed
      assert_equal "hello everybody", state.compress("hello everybody")
    end

    def test_decompress_when_compression_is_delayed_and_no_auth_hint_is_set_should_return_text
      state.set :compression => :delayed
      assert_equal "hello everybody", state.decompress("hello everybody")
    end

    def test_compress_when_compression_is_enabled_should_return_compressed_text
      state.set :compression => :standard     
      # JRuby Zlib implementation (1.4 & 1.5) does not have byte-to-byte compatibility with MRI's.
      # skip this test under JRuby.
      return if defined?(JRUBY_VERSION)
      assert_equal "x\234\312H\315\311\311WH-K-\252L\312O\251\004\000\000\000\377\377", state.compress("hello everybody")
    end

    def test_decompress_when_compression_is_enabled_should_return_decompressed_text
      state.set :compression => :standard     
      # JRuby Zlib implementation (1.4 & 1.5) does not have byte-to-byte compatibility with MRI's.
      # skip this test under JRuby.
      return if defined?(JRUBY_VERSION)
      assert_equal "hello everybody", state.decompress("x\234\312H\315\311\311WH-K-\252L\312O\251\004\000\000\000\377\377")
    end

    def test_compress_when_compression_is_delayed_and_auth_hint_is_set_should_return_compressed_text
      socket.hints[:authenticated] = true
      state.set :compression => :delayed
      assert_equal "x\234\312H\315\311\311WH-K-\252L\312O\251\004\000\000\000\377\377", state.compress("hello everybody")
    end

    def test_decompress_when_compression_is_delayed_and_auth_hint_is_set_should_return_decompressed_text
      socket.hints[:authenticated] = true
      state.set :compression => :delayed
      assert_equal "hello everybody", state.decompress("x\234\312H\315\311\311WH-K-\252L\312O\251\004\000\000\000\377\377")
    end

    def test_needs_rekey_should_be_true_if_packets_exceeds_max_packets
      state.set :max_packets => 2
      state.increment(8)
      state.increment(8)
      assert !state.needs_rekey?
      state.increment(8)
      assert state.needs_rekey?
    end

    def test_needs_rekey_should_be_true_if_blocks_exceeds_max_blocks
      state.set :max_blocks => 10
      assert !state.needs_rekey?
      state.increment(88)
      assert state.needs_rekey?
    end

    private

      def deflater(level=Zlib::DEFAULT_COMPRESSION)
        @deflater ||= Zlib::Deflate.new(level)
      end

      def inflater
        @inflater ||= Zlib::Inflate.new(nil)
      end

      def socket
        @socket ||= stub("socket", :hints => {})
      end

      def state
        @state ||= Net::SSH::Transport::State.new(socket, :test)
      end
  end

end