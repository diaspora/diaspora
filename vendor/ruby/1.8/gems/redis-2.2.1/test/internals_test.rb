# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require File.expand_path("./redis_mock", File.dirname(__FILE__))

include RedisMock::Helper

setup do
  log = StringIO.new

  [Redis.new(OPTIONS.merge(:logger => ::Logger.new(log))), log]
end

$TEST_PIPELINING = true

load File.expand_path("./lint/internals.rb", File.dirname(__FILE__))

test "provides a meaningful inspect" do |r, _|
  assert "#<Redis client v#{Redis::VERSION} connected to redis://127.0.0.1:6379/15 (Redis v#{r.info["redis_version"]})>" == r.inspect
end

test "Redis.current" do
  Redis.current.set("foo", "bar")

  assert "bar" == Redis.current.get("foo")

  Redis.current = Redis.new(OPTIONS.merge(:db => 14))

  assert Redis.current.get("foo").nil?
end

test "Timeout" do
  assert_nothing_raised do
    Redis.new(OPTIONS.merge(:timeout => 0))
  end
end

# Don't use assert_raise because Timeour::Error in 1.8 inherits
# Exception instead of StandardError (on 1.9).
test "Connection timeout" do
  # EM immediately raises CONNREFUSED
  next if driver == :synchrony

  result = false

  begin
    Redis.new(OPTIONS.merge(:host => "10.255.255.254", :timeout => 0.1)).ping
  rescue Timeout::Error
    result = true
  ensure
    assert result
  end
end

test "Retry when first read raises ECONNRESET" do
  $request = 0

  command = lambda do
    case ($request += 1)
    when 1; nil # Close on first command
    else "+%d" % $request
    end
  end

  redis_mock(:ping => command) do
    redis = Redis.connect(:port => 6380, :timeout => 0.1)
    assert "2" == redis.ping
  end
end

test "Don't retry when wrapped inside #without_reconnect" do
  $request = 0

  command = lambda do
    case ($request += 1)
    when 1; nil # Close on first command
    else "+%d" % $request
    end
  end

  redis_mock(:ping => command) do
    redis = Redis.connect(:port => 6380, :timeout => 0.1)
    assert_raise Errno::ECONNRESET do
      redis.without_reconnect do
        redis.ping
      end
    end

    assert !redis.client.connected?
  end
end

test "Retry only once when read raises ECONNRESET" do
  $request = 0

  command = lambda do
    case ($request += 1)
    when 1; nil # Close on first command
    when 2; nil # Close on second command
    else "+%d" % $request
    end
  end

  redis_mock(:ping => command) do
    redis = Redis.connect(:port => 6380, :timeout => 0.1)
    assert_raise Errno::ECONNRESET do
      redis.ping
    end

    assert !redis.client.connected?
  end
end

test "Don't retry when second read in pipeline raises ECONNRESET" do
  $request = 0

  command = lambda do
    case ($request += 1)
    when 2; nil # Close on second command
    else "+%d" % $request
    end
  end

  redis_mock(:ping => command) do
    redis = Redis.connect(:port => 6380, :timeout => 0.1)
    assert_raise Errno::ECONNRESET do
      redis.pipelined do
        redis.ping
        redis.ping # Second #read times out
      end
    end
  end
end

test "Connecting to UNIX domain socket" do
  assert_nothing_raised do
    Redis.new(OPTIONS.merge(:path => "/tmp/redis.sock")).ping
  end
end

# Using a mock server in a thread doesn't work here (possibly because blocking
# socket ops, raw socket timeouts and Ruby's thread scheduling don't mix).
test "Bubble EAGAIN without retrying" do
  cmd = %{(sleep 0.3; echo "+PONG\r\n") | nc -l 6380}
  IO.popen(cmd) do |_|
    sleep 0.1 # Give nc a little time to start listening
    redis = Redis.connect(:port => 6380, :timeout => 0.1)

    begin
      assert_raise(Errno::EAGAIN) { redis.ping }
    ensure
      # Explicitly close connection so nc can quit
      redis.client.disconnect

      # Make the reactor loop do a tick to really close
      EM::Synchrony.sleep(0) if driver == :synchrony
    end
  end
end

