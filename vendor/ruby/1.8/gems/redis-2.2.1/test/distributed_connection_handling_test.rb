# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "PING" do |r|
  assert ["PONG"] == r.ping
end

test "SELECT" do |r|
  r.set "foo", "bar"

  r.select 14
  assert nil == r.get("foo")

  r.select 15

  assert "bar" == r.get("foo")
end

