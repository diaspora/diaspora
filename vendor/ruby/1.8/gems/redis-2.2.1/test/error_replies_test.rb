# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

# Every test shouldn't disconnect from the server. Also, when error replies are
# in play, the protocol should never get into an invalid state where there are
# pending replies in the connection. Calling INFO after every test ensures that
# the protocol is still in a valid state.
def test_with_reconnection_check(title)
  test(title) do |r|
    before = r.info["total_connections_received"]
    yield(r)
    after = r.info["total_connections_received"]
    assert before == after
  end
end

test_with_reconnection_check "Error reply for single command" do |r|
  begin
    r.unknown_command
  rescue => ex
  ensure
    assert ex.message =~ /unknown command/i
  end
end

test_with_reconnection_check "Raise first error reply in pipeline" do |r|
  begin
    r.pipelined do
      r.set("foo", "s1")
      r.incr("foo") # not an integer
      r.lpush("foo", "value") # wrong kind of value
    end
  rescue => ex
  ensure
    assert ex.message =~ /not an integer/i
  end
end

test_with_reconnection_check "Recover from raise in #call_loop" do |r|
  begin
    r.client.call_loop([:invalid_monitor]) do
      assert false # Should never be executed
    end
  rescue => ex
  ensure
    assert ex.message =~ /unknown command/i
  end
end
