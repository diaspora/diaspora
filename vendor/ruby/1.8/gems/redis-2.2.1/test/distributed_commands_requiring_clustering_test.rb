# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "RENAME" do |r|
  r.set("{qux}foo", "s1")
  r.rename "{qux}foo", "{qux}bar"

  assert "s1" == r.get("{qux}bar")
  assert nil == r.get("{qux}foo")
end

test "RENAMENX" do |r|
  r.set("{qux}foo", "s1")
  r.set("{qux}bar", "s2")

  assert false == r.renamenx("{qux}foo", "{qux}bar")

  assert "s1" == r.get("{qux}foo")
  assert "s2" == r.get("{qux}bar")
end

test "BRPOPLPUSH" do |r|
  r.rpush "{qux}foo", "s1"
  r.rpush "{qux}foo", "s2"

  assert_equal "s2", r.brpoplpush("{qux}foo", "{qux}bar", 1)
  assert_equal ["s2"], r.lrange("{qux}bar", 0, -1)
end

test "RPOPLPUSH" do |r|
  r.rpush "{qux}foo", "s1"
  r.rpush "{qux}foo", "s2"

  assert "s2" == r.rpoplpush("{qux}foo", "{qux}bar")
  assert ["s2"] == r.lrange("{qux}bar", 0, -1)
  assert "s1" == r.rpoplpush("{qux}foo", "{qux}bar")
  assert ["s1", "s2"] == r.lrange("{qux}bar", 0, -1)
end

test "SMOVE" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}bar", "s2"

  assert r.smove("{qux}foo", "{qux}bar", "s1")
  assert r.sismember("{qux}bar", "s1")
end

test "SINTER" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"

  assert ["s2"] == r.sinter("{qux}foo", "{qux}bar")
end

test "SINTERSTORE" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"

  r.sinterstore("{qux}baz", "{qux}foo", "{qux}bar")

  assert ["s2"] == r.smembers("{qux}baz")
end

test "SUNION" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"
  r.sadd "{qux}bar", "s3"

  assert ["s1", "s2", "s3"] == r.sunion("{qux}foo", "{qux}bar").sort
end

test "SUNIONSTORE" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"
  r.sadd "{qux}bar", "s3"

  r.sunionstore("{qux}baz", "{qux}foo", "{qux}bar")

  assert ["s1", "s2", "s3"] == r.smembers("{qux}baz").sort
end

test "SDIFF" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"
  r.sadd "{qux}bar", "s3"

  assert ["s1"] == r.sdiff("{qux}foo", "{qux}bar")
  assert ["s3"] == r.sdiff("{qux}bar", "{qux}foo")
end

test "SDIFFSTORE" do |r|
  r.sadd "{qux}foo", "s1"
  r.sadd "{qux}foo", "s2"
  r.sadd "{qux}bar", "s2"
  r.sadd "{qux}bar", "s3"

  r.sdiffstore("{qux}baz", "{qux}foo", "{qux}bar")

  assert ["s1"] == r.smembers("{qux}baz")
end

test "SORT" do |r|
  r.set("{qux}foo:1", "s1")
  r.set("{qux}foo:2", "s2")

  r.rpush("{qux}bar", "1")
  r.rpush("{qux}bar", "2")

  assert ["s1"] == r.sort("{qux}bar", :get => "{qux}foo:*", :limit => [0, 1])
  assert ["s2"] == r.sort("{qux}bar", :get => "{qux}foo:*", :limit => [0, 1], :order => "desc alpha")
end

test "SORT with an array of GETs" do |r|
  r.set("{qux}foo:1:a", "s1a")
  r.set("{qux}foo:1:b", "s1b")

  r.set("{qux}foo:2:a", "s2a")
  r.set("{qux}foo:2:b", "s2b")

  r.rpush("{qux}bar", "1")
  r.rpush("{qux}bar", "2")

  assert ["s1a", "s1b"] == r.sort("{qux}bar", :get => ["{qux}foo:*:a", "{qux}foo:*:b"], :limit => [0, 1])
  assert ["s2a", "s2b"] == r.sort("{qux}bar", :get => ["{qux}foo:*:a", "{qux}foo:*:b"], :limit => [0, 1], :order => "desc alpha")
end

test "SORT with STORE" do |r|
  r.set("{qux}foo:1", "s1")
  r.set("{qux}foo:2", "s2")

  r.rpush("{qux}bar", "1")
  r.rpush("{qux}bar", "2")

  r.sort("{qux}bar", :get => "{qux}foo:*", :store => "{qux}baz")
  assert ["s1", "s2"] == r.lrange("{qux}baz", 0, -1)
end
