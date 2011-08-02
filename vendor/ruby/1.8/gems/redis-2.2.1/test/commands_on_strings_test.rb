# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

load './test/lint/strings.rb'

test "MGET" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  assert ["s1", "s2"]      == r.mget("foo", "bar")
  assert ["s1", "s2", nil] == r.mget("foo", "bar", "baz")
end

test "MGET mapped" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  response = r.mapped_mget("foo", "bar")

  assert "s1" == response["foo"]
  assert "s2" == response["bar"]

  response = r.mapped_mget("foo", "bar", "baz")

  assert "s1" == response["foo"]
  assert "s2" == response["bar"]
  assert nil  == response["baz"]
end

test "Mapped MGET in a pipeline returns plain array" do |r|
  r.set("foo", "s1")
  r.set("bar", "s2")

  result = r.pipelined do
    assert nil == r.mapped_mget("foo", "bar")
  end

  assert result[0] == ["s1", "s2"]
end

test "MSET" do |r|
  r.mset(:foo, "s1", :bar, "s2")

  assert "s1" == r.get("foo")
  assert "s2" == r.get("bar")
end

test "MSET mapped" do |r|
  r.mapped_mset(:foo => "s1", :bar => "s2")

  assert "s1" == r.get("foo")
  assert "s2" == r.get("bar")
end

test "MSETNX" do |r|
  r.set("foo", "s1")
  r.msetnx(:foo, "s2", :bar, "s3")

  assert "s1" == r.get("foo")
  assert nil == r.get("bar")
end

test "MSETNX mapped" do |r|
  r.set("foo", "s1")
  r.mapped_msetnx(:foo => "s2", :bar => "s3")

  assert "s1" == r.get("foo")
  assert nil == r.get("bar")
end

test "STRLEN" do |r|
  r.set "foo", "lorem"

  assert 5 == r.strlen("foo")
end
