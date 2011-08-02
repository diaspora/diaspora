# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init(Redis::Distributed.new(NODES, :logger => ::Logger.new(log)))
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
  assert_raise Redis::Distributed::CannotDistribute do
    r.randomkey
  end
end

test "RENAME" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.set("foo", "s1")
    r.rename "foo", "bar"
  end

  assert "s1" == r.get("foo")
  assert nil == r.get("bar")
end

test "RENAMENX" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.set("foo", "s1")
    r.rename "foo", "bar"
  end

  assert "s1" == r.get("foo")
  assert nil  == r.get("bar")
end

test "DBSIZE" do |r|
  assert [0] == r.dbsize

  r.set("foo", "s1")

  assert [1] == r.dbsize
end

test "FLUSHDB" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  assert [2] == r.dbsize

  r.flushdb

  assert [0] == r.dbsize
end

