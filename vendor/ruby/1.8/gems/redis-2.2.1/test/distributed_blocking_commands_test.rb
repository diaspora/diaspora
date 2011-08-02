# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "BLPOP" do |r|
  r.lpush("foo", "s1")
  r.lpush("foo", "s2")

  wire = Wire.new do
    redis = Redis::Distributed.new(NODES)
    Wire.sleep 0.3
    redis.lpush("foo", "s3")
  end

  assert ["foo", "s2"] == r.blpop("foo", 1)
  assert ["foo", "s1"] == r.blpop("foo", 1)
  assert ["foo", "s3"] == r.blpop("foo", 1)

  wire.join
end

test "BRPOP" do |r|
  r.rpush("foo", "s1")
  r.rpush("foo", "s2")

  wire = Wire.new do
    redis = Redis::Distributed.new(NODES)
    Wire.sleep 0.3
    redis.rpush("foo", "s3")
  end

  assert ["foo", "s2"] == r.brpop("foo", 1)
  assert ["foo", "s1"] == r.brpop("foo", 1)
  assert ["foo", "s3"] == r.brpop("foo", 1)

  wire.join
end

test "BRPOP should unset a configured socket timeout" do |r|
  r = Redis::Distributed.new(NODES, :timeout => 1)

  assert_nothing_raised do
    r.brpop("foo", 2)
  end # Errno::EAGAIN raised if socket times out before redis command times out

  assert r.nodes.all? { |node| node.client.timeout == 1 }
end
