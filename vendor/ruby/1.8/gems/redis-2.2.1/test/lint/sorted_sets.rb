test "ZADD" do |r|
  assert 0 == r.zcard("foo")

  r.zadd "foo", 1, "s1"

  assert 1 == r.zcard("foo")
end

test "ZREM" do |r|
  r.zadd "foo", 1, "s1"

  assert 1 == r.zcard("foo")

  r.zadd "foo", 2, "s2"

  assert 2 == r.zcard("foo")

  r.zrem "foo", "s1"

  assert 1 == r.zcard("foo")
end

test "ZINCRBY" do |r|
  r.zincrby "foo", 1, "s1"

  assert "1" == r.zscore("foo", "s1")

  r.zincrby "foo", 10, "s1"

  assert "11" == r.zscore("foo", "s1")
end

test "ZRANK" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert 2 == r.zrank("foo", "s3")
end

test "ZREVRANK" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert 0 == r.zrevrank("foo", "s3")
end

test "ZRANGE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert ["s1", "s2"] == r.zrange("foo", 0, 1)
  assert ["s1", "1", "s2", "2"] == r.zrange("foo", 0, 1, :with_scores => true)
  assert ["s1", "1", "s2", "2"] == r.zrange("foo", 0, 1, :withscores => true)
end

test "ZREVRANGE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert ["s3", "s2"] == r.zrevrange("foo", 0, 1)
  assert ["s3", "3", "s2", "2"] == r.zrevrange("foo", 0, 1, :with_scores => true)
  assert ["s3", "3", "s2", "2"] == r.zrevrange("foo", 0, 1, :withscores => true)
end

test "ZRANGEBYSCORE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert ["s2", "s3"] == r.zrangebyscore("foo", 2, 3)
end

test "ZREVRANGEBYSCORE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert ["s3", "s2"] == r.zrevrangebyscore("foo", 3, 2)
end

test "ZRANGEBYSCORE with LIMIT" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "foo", 4, "s4"

  assert ["s2"] == r.zrangebyscore("foo", 2, 4, :limit => [0, 1])
  assert ["s3"] == r.zrangebyscore("foo", 2, 4, :limit => [1, 1])
  assert ["s3", "s4"] == r.zrangebyscore("foo", 2, 4, :limit => [1, 2])
end

test "ZREVRANGEBYSCORE with LIMIT" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "foo", 4, "s4"

  assert ["s4"] == r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1])
  assert ["s3"] == r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1])
  assert ["s3", "s2"] == r.zrevrangebyscore("foo", 4, 2, :limit => [1, 2])
end

test "ZRANGEBYSCORE with WITHSCORES" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "foo", 4, "s4"

  assert ["s2", "2"] == r.zrangebyscore("foo", 2, 4, :limit => [0, 1], :with_scores => true)
  assert ["s3", "3"] == r.zrangebyscore("foo", 2, 4, :limit => [1, 1], :with_scores => true)
  assert ["s2", "2"] == r.zrangebyscore("foo", 2, 4, :limit => [0, 1], :withscores => true)
  assert ["s3", "3"] == r.zrangebyscore("foo", 2, 4, :limit => [1, 1], :withscores => true)
end

test "ZREVRANGEBYSCORE with WITHSCORES" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "foo", 4, "s4"

  assert ["s4", "4"] == r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1], :with_scores => true)
  assert ["s3", "3"] == r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1], :with_scores => true)
  assert ["s4", "4"] == r.zrevrangebyscore("foo", 4, 2, :limit => [0, 1], :withscores => true)
  assert ["s3", "3"] == r.zrevrangebyscore("foo", 4, 2, :limit => [1, 1], :withscores => true)
end

test "ZCARD" do |r|
  assert 0 == r.zcard("foo")

  r.zadd "foo", 1, "s1"

  assert 1 == r.zcard("foo")
end

test "ZSCORE" do |r|
  r.zadd "foo", 1, "s1"

  assert "1" == r.zscore("foo", "s1")

  assert nil == r.zscore("foo", "s2")
  assert nil == r.zscore("bar", "s1")
end

test "ZREMRANGEBYRANK" do |r|
  r.zadd "foo", 10, "s1"
  r.zadd "foo", 20, "s2"
  r.zadd "foo", 30, "s3"
  r.zadd "foo", 40, "s4"

  assert 3 == r.zremrangebyrank("foo", 1, 3)
  assert ["s1"] == r.zrange("foo", 0, -1)
end

test "ZREMRANGEBYSCORE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "foo", 4, "s4"

  assert 3 == r.zremrangebyscore("foo", 2, 4)
  assert ["s1"] == r.zrange("foo", 0, -1)
end

