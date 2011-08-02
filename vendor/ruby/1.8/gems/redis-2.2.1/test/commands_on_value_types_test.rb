# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require File.expand_path("./redis_mock", File.dirname(__FILE__))

include RedisMock::Helper

setup do
  init Redis.new(OPTIONS)
end

load "./test/lint/value_types.rb"

test "DEL" do |r|
  r.set "foo", "s1"
  r.set "bar", "s2"
  r.set "baz", "s3"

  assert ["bar", "baz", "foo"] == r.keys("*").sort

  assert 1 == r.del("foo")

  assert ["bar", "baz"] == r.keys("*").sort

  assert 2 == r.del("bar", "baz")

  assert [] == r.keys("*").sort
end

test "RANDOMKEY" do |r|
  assert r.randomkey.to_s.empty?

  r.set("foo", "s1")

  assert "foo" == r.randomkey

  r.set("bar", "s2")

  4.times do
    assert ["foo", "bar"].include?(r.randomkey)
  end
end

test "RENAME" do |r|
  r.set("foo", "s1")
  r.rename "foo", "bar"

  assert "s1" == r.get("bar")
  assert nil == r.get("foo")
end

test "RENAMENX" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  assert false == r.renamenx("foo", "bar")

  assert "s1" == r.get("foo")
  assert "s2" == r.get("bar")
end

test "DBSIZE" do |r|
  assert 0 == r.dbsize

  r.set("foo", "s1")

  assert 1 == r.dbsize
end

test "FLUSHDB" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  assert 2 == r.dbsize

  r.flushdb

  assert 0 == r.dbsize
end

test "FLUSHALL" do
  redis_mock(:flushall => lambda { "+FLUSHALL" }) do
    redis = Redis.new(OPTIONS.merge(:port => 6380))

    assert "FLUSHALL" == redis.flushall
  end
end

