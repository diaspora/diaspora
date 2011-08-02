# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

load './test/lint/lists.rb'

test "RPUSHX" do |r|
  r.rpushx "foo", "s1"
  r.rpush "foo", "s2"
  r.rpushx "foo", "s3"

  assert 2 == r.llen("foo")
  assert ["s2", "s3"] == r.lrange("foo", 0, -1)
end

test "LPUSHX" do |r|
  r.lpushx "foo", "s1"
  r.lpush "foo", "s2"
  r.lpushx "foo", "s3"

  assert 2 == r.llen("foo")
  assert ["s3", "s2"] == r.lrange("foo", 0, -1)
end

test "LINSERT" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s3"
  r.linsert "foo", :before, "s3", "s2"

  assert ["s1", "s2", "s3"] == r.lrange("foo", 0, -1)

  assert_raise(RuntimeError) do
    r.linsert "foo", :anywhere, "s3", "s2"
  end
end

test "RPOPLPUSH" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert "s2" == r.rpoplpush("foo", "bar")
  assert ["s2"] == r.lrange("bar", 0, -1)
  assert "s1" == r.rpoplpush("foo", "bar")
  assert ["s1", "s2"] == r.lrange("bar", 0, -1)
end

test "BRPOPLPUSH" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert_equal "s2", r.brpoplpush("foo", "bar", 1)

  assert_equal nil, r.brpoplpush("baz", "qux", 1)

  assert_equal ["s2"], r.lrange("bar", 0, -1)
end
