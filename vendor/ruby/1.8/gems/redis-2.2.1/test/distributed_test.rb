# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "handle multiple servers" do
  @r = Redis::Distributed.new ["redis://localhost:6379/15", *NODES]

  100.times do |idx|
    @r.set(idx.to_s, "foo#{idx}")
  end

  100.times do |idx|
    assert "foo#{idx}" == @r.get(idx.to_s)
  end

  assert "0" == @r.keys("*").sort.first
  assert "string" == @r.type("1")
end

test "add nodes" do
  logger = Logger.new("/dev/null")

  @r = Redis::Distributed.new NODES, :logger => logger, :timeout => 10

  assert "127.0.0.1" == @r.nodes[0].client.host
  assert 6379 == @r.nodes[0].client.port
  assert 15 == @r.nodes[0].client.db
  assert 10 == @r.nodes[0].client.timeout
  assert logger == @r.nodes[0].client.logger

  @r.add_node("redis://localhost:6380/14")

  assert "localhost" == @r.nodes[1].client.host
  assert 6380 == @r.nodes[1].client.port
  assert 14 == @r.nodes[1].client.db
  assert 10 == @r.nodes[1].client.timeout
  assert logger == @r.nodes[1].client.logger
end

test "Pipelining commands cannot be distributed" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.pipelined do
      r.lpush "foo", "s1"
      r.lpush "foo", "s2"
    end
  end
end

test "Unknown commands does not work by default" do |r|
  assert_raise NoMethodError do
    r.not_yet_implemented_command
  end
end
