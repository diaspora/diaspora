require 'test/unit'
require 'mocha'
require 'stringio'

begin
  require 'net/ssh'
  require 'net/ssh/version'
  raise LoadError, "wrong version" unless Net::SSH::Version::STRING >= '1.99.0'
rescue LoadError
  begin
    gem 'net-ssh', ">= 2.0.0"
    require 'net/ssh'
  rescue LoadError => e
    abort "could not load net/ssh v2 (#{e.inspect})"
  end
end

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'net/sftp'
require 'net/sftp/constants'
require 'net/ssh/test'

class Net::SFTP::TestCase < Test::Unit::TestCase
  include Net::SFTP::Constants::PacketTypes
  include Net::SSH::Test

  def default_test
    # do nothing, this is just hacky-hack to work around Test::Unit's
    # insistence that all TestCase subclasses have at least one test
    # method defined.
  end

  protected

    def raw(*args)
      Net::SSH::Buffer.from(*args).to_s
    end

    def sftp(options={})
      @sftp ||= Net::SFTP::Session.new(connection(options))
    end

    def expect_sftp_session(opts={})
      story do |session|
        channel = session.opens_channel
        channel.sends_subsystem("sftp")
        channel.sends_packet(FXP_INIT, :long, opts[:client_version] || Net::SFTP::Session::HIGHEST_PROTOCOL_VERSION_SUPPORTED)
        channel.gets_packet(FXP_VERSION, :long, opts[:server_version] || Net::SFTP::Session::HIGHEST_PROTOCOL_VERSION_SUPPORTED)
        yield channel if block_given?
      end
    end

    def assert_scripted_command
      assert_scripted do
        sftp.connect!
        yield
        sftp.loop
      end
    end

    def assert_progress_reported_open(expect={})
      assert_progress_reported(:open, expect)
    end

    def assert_progress_reported_put(offset, data, expect={})
      assert_equal offset, current_event[3] if offset
      assert_equal data, current_event[4] if data
      assert_progress_reported(:put, expect)
    end

    def assert_progress_reported_get(offset, data, expect={})
      assert_equal offset, current_event[3] if offset
      if data.is_a?(Fixnum)
        assert_equal data, current_event[4].length
      elsif data
        assert_equal data, current_event[4]
      end
      assert_progress_reported(:get, expect)
    end

    def assert_progress_reported_close(expect={})
      assert_progress_reported(:close, expect)
    end

    def assert_progress_reported_mkdir(dir)
      assert_equal dir, current_event[2]
      assert_progress_reported(:mkdir)
    end

    def assert_progress_reported_finish
      assert_progress_reported(:finish)
    end

    def assert_progress_reported(event, expect={})
      assert_equal event, current_event[0]
      expect.each do |key, value|
        assert_equal value, current_event[2].send(key)
      end
      next_event!
    end

    def assert_no_more_reported_events
      assert @progress.empty?, "expected #{@progress.empty?} to be empty"
    end

    def prepare_progress!
      @progress = []
    end

    def record_progress(event)
      @progress << event
    end

    def current_event
      @progress.first
    end

    def next_event!
      @progress.shift
    end
end

class Net::SSH::Test::Channel
  def gets_packet(type, *args)
    gets_data(sftp_packet(type, *args))
  end

  def sends_packet(type, *args)
    sends_data(sftp_packet(type, *args))
  end

  private

    def sftp_packet(type, *args)
      data = Net::SSH::Buffer.from(*args)
      Net::SSH::Buffer.from(:long, data.length+1, :byte, type, :raw, data).to_s
    end
end

class ProgressHandler
  def initialize(progress_ref)
    @progress = progress_ref
  end

  def on_open(*args)
    @progress << [:open, *args]
  end

  def on_put(*args)
    @progress << [:put, *args]
  end

  def on_close(*args)
    @progress << [:close, *args]
  end

  def on_finish(*args)
    @progress << [:finish, *args]
  end
end

# "prime the pump", so to speak: predefine the modules we need so we can
# define the test classes in a more elegant short-hand.

module Protocol
  module V01; end
  module V02; end
  module V03; end
  module V04; end
  module V05; end
  module V06; end
end
