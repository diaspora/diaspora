test "RPUSH" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert 2 == r.llen("foo")
  assert "s2" == r.rpop("foo")
end

test "LPUSH" do |r|
  r.lpush "foo", "s1"
  r.lpush "foo", "s2"

  assert 2 == r.llen("foo")
  assert "s2" == r.lpop("foo")
end

test "LLEN" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert 2 == r.llen("foo")
end

test "LRANGE" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"
  r.rpush "foo", "s3"

  assert ["s2", "s3"] == r.lrange("foo", 1, -1)
  assert ["s1", "s2"] == r.lrange("foo", 0, 1)

  assert [] == r.lrange("bar", 0, -1)
end

test "LTRIM" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"
  r.rpush "foo", "s3"

  r.ltrim "foo", 0, 1

  assert 2 == r.llen("foo")
  assert ["s1", "s2"] == r.lrange("foo", 0, -1)
end

test "LINDEX" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert "s1" == r.lindex("foo", 0)
  assert "s2" == r.lindex("foo", 1)
end

test "LSET" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert "s2" == r.lindex("foo", 1)
  assert r.lset("foo", 1, "s3")
  assert "s3" == r.lindex("foo", 1)

  assert_raise RuntimeError do
    r.lset("foo", 4, "s3")
  end
end

test "LREM" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert 1 == r.lrem("foo", 1, "s1")
  assert ["s2"] == r.lrange("foo", 0, -1)
end

test "LPOP" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert 2 == r.llen("foo")
  assert "s1" == r.lpop("foo")
  assert 1 == r.llen("foo")
end

test "RPOP" do |r|
  r.rpush "foo", "s1"
  r.rpush "foo", "s2"

  assert 2 == r.llen("foo")
  assert "s2" == r.rpop("foo")
  assert 1 == r.llen("foo")
end


