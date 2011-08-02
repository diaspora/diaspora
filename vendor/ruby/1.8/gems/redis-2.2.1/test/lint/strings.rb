test "SET and GET" do |r|
  r.set("foo", "s1")

  assert "s1" == r.get("foo")
end

test "SET and GET with brackets" do |r|
  r["foo"] = "s1"

  assert "s1" == r["foo"]
end

test "SET and GET with brackets and symbol" do |r|
  r[:foo] = "s1"

  assert "s1" == r[:foo]
end

test "SET and GET with newline characters" do |r|
  r.set("foo", "1\n")

  assert "1\n" == r.get("foo")
end

test "SET and GET with ASCII characters" do |r|
  with_external_encoding("ASCII-8BIT") do
    (0..255).each do |i|
      str = "#{i.chr}---#{i.chr}"
      r.set("foo", str)

      assert str == r.get("foo")
    end
  end
end if defined?(Encoding)

test "SETEX" do |r|
  r.setex("foo", 1, "s1")

  assert "s1" == r.get("foo")

  sleep 2

  assert nil == r.get("foo")
end

test "GETSET" do |r|
  r.set("foo", "bar")

  assert "bar" == r.getset("foo", "baz")
  assert "baz" == r.get("foo")
end

test "SETNX" do |r|
  r.set("foo", "s1")

  assert "s1" == r.get("foo")

  r.setnx("foo", "s2")

  assert "s1" == r.get("foo")
end

test "INCR" do |r|
  assert 1 == r.incr("foo")
  assert 2 == r.incr("foo")
  assert 3 == r.incr("foo")
end

test "INCRBY" do |r|
  assert 1 == r.incrby("foo", 1)
  assert 3 == r.incrby("foo", 2)
  assert 6 == r.incrby("foo", 3)
end

test "DECR" do |r|
  r.set("foo", 3)

  assert 2 == r.decr("foo")
  assert 1 == r.decr("foo")
  assert 0 == r.decr("foo")
end

test "DECRBY" do |r|
  r.set("foo", 6)

  assert 3 == r.decrby("foo", 3)
  assert 1 == r.decrby("foo", 2)
  assert 0 == r.decrby("foo", 1)
end

test "APPEND" do |r|
  r.set "foo", "s"
  r.append "foo", "1"

  assert "s1" == r.get("foo")
end

test "SUBSTR" do |r|
  r.set "foo", "lorem"

  assert "ore" == r.substr("foo", 1, 3)
end

test "GETBIT" do |r|
  r.set("foo", "a")

  assert_equal 1, r.getbit("foo", 1)
  assert_equal 1, r.getbit("foo", 2)
  assert_equal 0, r.getbit("foo", 3)
  assert_equal 0, r.getbit("foo", 4)
  assert_equal 0, r.getbit("foo", 5)
  assert_equal 0, r.getbit("foo", 6)
  assert_equal 1, r.getbit("foo", 7)
end

test "SETBIT" do |r|
  r.set("foo", "a")

  r.setbit("foo", 6, 1)

  assert_equal "c", r.get("foo")
end

test "GETRANGE" do |r|
  r.set("foo", "abcde")

  assert_equal "bcd", r.getrange("foo", 1, 3)
  assert_equal "abcde", r.getrange("foo", 0, -1)
end

test "SETRANGE" do |r|
  r.set("foo", "abcde")

  r.setrange("foo", 1, "bar")

  assert_equal "abare", r.get("foo")
end
