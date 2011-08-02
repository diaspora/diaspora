# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "INFO" do |r|
  %w(last_save_time redis_version total_connections_received connected_clients total_commands_processed connected_slaves uptime_in_seconds used_memory uptime_in_days changes_since_last_save).each do |x|
    r.info.each do |info|
      assert info.keys.include?(x)
    end
  end
end

test "INFO COMMANDSTATS" do |r|
  # Only available on Redis >= 2.3.0
  next if r.info.first["redis_version"] < "2.3.0"

  r.nodes.each { |n| n.config(:resetstat) }
  r.ping # Executed on every node

  r.info(:commandstats).each do |info|
    assert "1" == info["ping"]["calls"]
  end
end

test "MONITOR" do |r|
  begin
    r.monitor
  rescue Exception => ex
  ensure
    assert ex.kind_of?(NotImplementedError)
  end
end

test "ECHO" do |r|
  assert ["foo bar baz\n"] == r.echo("foo bar baz\n")
end

