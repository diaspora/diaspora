test "EXISTS" do |r|
  assert false == r.exists("foo")

  r.set("foo", "s1")

  assert true ==  r.exists("foo")
end

test "TYPE" do |r|
  assert "none" == r.type("foo")

  r.set("foo", "s1")

  assert "string" == r.type("foo")
end

test "KEYS" do |r|
  r.set("f", "s1")
  r.set("fo", "s2")
  r.set("foo", "s3")

  assert ["f","fo", "foo"] == r.keys("f*").sort
end

test "EXPIRE" do |r|
  r.set("foo", "s1")
  r.expire("foo", 1)

  assert "s1" == r.get("foo")

  sleep 2

  assert nil == r.get("foo")
end

test "EXPIREAT" do |r|
  r.set("foo", "s1")
  r.expireat("foo", Time.now.to_i + 1)

  assert "s1" == r.get("foo")

  sleep 2

  assert nil == r.get("foo")
end

test "PERSIST" do |r|
  r.set("foo", "s1")
  r.expire("foo", 1)
  r.persist("foo")

  assert(-1 == r.ttl("foo"))
end

test "TTL" do |r|
  r.set("foo", "s1")
  r.expire("foo", 1)

  assert 1 == r.ttl("foo")
end

test "MOVE" do |r|
  r.select 14
  r.flushdb

  r.set "bar", "s3"

  r.select 15

  r.set "foo", "s1"
  r.set "bar", "s2"

  assert r.move("foo", 14)
  assert nil == r.get("foo")

  assert !r.move("bar", 14)
  assert "s2" == r.get("bar")

  r.select 14

  assert "s1" == r.get("foo")
  assert "s3" == r.get("bar")
end

