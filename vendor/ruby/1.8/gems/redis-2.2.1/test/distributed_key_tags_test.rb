# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "hashes consistently" do
  r1 = Redis::Distributed.new ["redis://localhost:6379/15", *NODES]
  r2 = Redis::Distributed.new ["redis://localhost:6379/15", *NODES]
  r3 = Redis::Distributed.new ["redis://localhost:6379/15", *NODES]

  assert r1.node_for("foo").id == r2.node_for("foo").id
  assert r1.node_for("foo").id == r3.node_for("foo").id
end

test "allows clustering of keys" do |r|
  r = Redis::Distributed.new(NODES)
  r.add_node("redis://localhost:6379/14")
  r.flushdb

  100.times do |i|
    r.set "{foo}users:#{i}", i
  end

  assert [0, 100] == r.nodes.map { |node| node.keys.size }
end

test "distributes keys if no clustering is used" do |r|
  r.add_node("redis://localhost:6379/14")
  r.flushdb

  r.set "users:1", 1
  r.set "users:4", 4

  assert [1, 1] == r.nodes.map { |node| node.keys.size }
end

test "allows passing a custom tag extractor" do |r|
  r = Redis::Distributed.new(NODES, :tag => /^(.+?):/)
  r.add_node("redis://localhost:6379/14")
  r.flushdb

  100.times do |i|
    r.set "foo:users:#{i}", i
  end

  assert [0, 100] == r.nodes.map { |node| node.keys.size }
end

