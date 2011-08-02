# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

test "MULTI/DISCARD" do |r|
  r.multi

  assert "QUEUED" == r.set("foo", "1")
  assert "QUEUED" == r.get("foo")

  r.discard

  assert nil == r.get("foo")
end

test "MULTI/EXEC with a block" do |r|
  r.multi do |multi|
    multi.set "foo", "s1"
  end

  assert "s1" == r.get("foo")

  assert_raise(RuntimeError) do
    r.multi do |multi|
      multi.set "bar", "s2"
      raise "Some error"
      multi.set "baz", "s3"
    end
  end

  assert nil == r.get("bar")
  assert nil == r.get("baz")
end

test "Don't raise (and ignore) immediate error in MULTI/EXEC" do |r|
  result = r.multi do |m|
    m.set("foo", "s1")
    m.unknown_command
  end

  assert 1 == result.size
  assert "OK" == result.first
  assert "s1" == r.get("foo")
end

test "Don't raise delayed error in MULTI/EXEC" do |r|
  result = r.multi do |m|
    m.set("foo", "s1")
    m.incr("foo") # not an integer
    m.lpush("foo", "value") # wrong kind of value
  end

  assert result[1].message =~ /not an integer/i
  assert result[2].message =~ /wrong kind of value/i
  assert "s1" == r.get("foo")
end

test "MULTI with a block yielding the client" do |r|
  r.multi do |multi|
    multi.set "foo", "s1"
  end

  assert "s1" == r.get("foo")
end

test "WATCH with an unmodified key" do |r|
  r.watch "foo"
  r.multi do |multi|
    multi.set "foo", "s1"
  end

  assert "s1" == r.get("foo")
end

test "WATCH with a modified key" do |r|
  r.watch "foo"
  r.set "foo", "s1"
  res = r.multi do |multi|
    multi.set "foo", "s2"
  end

  assert nil == res
  assert "s1" == r.get("foo")
end

test "UNWATCH with a modified key" do |r|
  r.watch "foo"
  r.set "foo", "s1"
  r.unwatch
  r.multi do |multi|
    multi.set "foo", "s2"
  end

  assert "s2" == r.get("foo")
end

