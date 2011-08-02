test "HSET and HGET" do |r|
  r.hset("foo", "f1", "s1")

  assert "s1" == r.hget("foo", "f1")
end

test "HDEL" do |r|
  r.hset("foo", "f1", "s1")

  assert "s1" == r.hget("foo", "f1")

  r.hdel("foo", "f1")

  assert nil == r.hget("foo", "f1")
end

test "HEXISTS" do |r|
  assert false == r.hexists("foo", "f1")

  r.hset("foo", "f1", "s1")

  assert r.hexists("foo", "f1")
end

test "HLEN" do |r|
  assert 0 == r.hlen("foo")

  r.hset("foo", "f1", "s1")

  assert 1 == r.hlen("foo")

  r.hset("foo", "f2", "s2")

  assert 2 == r.hlen("foo")
end

test "HKEYS" do |r|
  assert [] == r.hkeys("foo")

  r.hset("foo", "f1", "s1")
  r.hset("foo", "f2", "s2")

  assert ["f1", "f2"] == r.hkeys("foo")
end

test "HVALS" do |r|
  assert [] == r.hvals("foo")

  r.hset("foo", "f1", "s1")
  r.hset("foo", "f2", "s2")

  assert ["s1", "s2"] == r.hvals("foo")
end

test "HGETALL" do |r|
  assert({} == r.hgetall("foo"))

  r.hset("foo", "f1", "s1")
  r.hset("foo", "f2", "s2")

  assert({"f1" => "s1", "f2" => "s2"} == r.hgetall("foo"))
end

test "HMSET" do |r|
  r.hmset("hash", "foo1", "bar1", "foo2", "bar2")

  assert "bar1" == r.hget("hash", "foo1")
  assert "bar2" == r.hget("hash", "foo2")
end

test "HMSET with invalid arguments" do |r|
  assert_raise(RuntimeError) do
    r.hmset("hash", "foo1", "bar1", "foo2", "bar2", "foo3")
  end
end

test "Mapped HMSET" do |r|
  r.mapped_hmset("foo", :f1 => "s1", :f2 => "s2")

  assert "s1" == r.hget("foo", "f1")
  assert "s2" == r.hget("foo", "f2")
end

test "HMGET" do |r|
  r.hset("foo", "f1", "s1")
  r.hset("foo", "f2", "s2")
  r.hset("foo", "f3", "s3")

  assert ["s2", "s3"] == r.hmget("foo", "f2", "f3")
end

test "HMGET mapped" do |r|
  r.hset("foo", "f1", "s1")
  r.hset("foo", "f2", "s2")
  r.hset("foo", "f3", "s3")

  assert({"f1" => "s1"} == r.mapped_hmget("foo", "f1"))
  assert({"f1" => "s1", "f2" => "s2"} == r.mapped_hmget("foo", "f1", "f2"))
end

test "HINCRBY" do |r|
  r.hincrby("foo", "f1", 1)

  assert "1" == r.hget("foo", "f1")

  r.hincrby("foo", "f1", 2)

  assert "3" == r.hget("foo", "f1")

  r.hincrby("foo", "f1", -1)

  assert "2" == r.hget("foo", "f1")
end

