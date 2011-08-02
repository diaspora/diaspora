test "Logger" do |r, log|
  r.ping

  assert log.string =~ /Redis >> PING/
  assert log.string =~ /Redis >> \d+\.\d+ms/
end

test "Logger with pipelining" do |r, log|
  r.pipelined do
    r.set "foo", "bar"
    r.get "foo"
  end

  assert log.string["SET foo bar"]
  assert log.string["GET foo"]
end if $TEST_PIPELINING

test "Recovers from failed commands" do |r, _|
  # See http://github.com/ezmobius/redis-rb/issues#issue/28

  assert_raise(ArgumentError) do
    r.srem "foo"
  end

  assert_nothing_raised do
    r.info
  end
end

test "raises on protocol errors" do
  redis_mock(:ping => lambda { |*_| "foo" }) do
    assert_raise(Redis::ProtocolError) do
      Redis.connect(:port => 6380).ping
    end
  end
end

