require './test/test_helper'

class DBAPITest < Test::Unit::TestCase
  include Mongo
  include BSON

  @@conn = Connection.new(ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost',
                        ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT)
  @@db   = @@conn.db(MONGO_TEST_DB)
  @@coll = @@db.collection('test')
  @@version = @@conn.server_version

  def setup
    @@coll.remove
    @r1 = {'a' => 1}
    @@coll.insert(@r1) # collection not created until it's used
    @@coll_full_name = "#{MONGO_TEST_DB}.test"
  end

  def teardown
    @@coll.remove
    @@db.get_last_error
  end

  def test_clear
    assert_equal 1, @@coll.count
    @@coll.remove
    assert_equal 0, @@coll.count
  end

  def test_insert
    assert_kind_of BSON::ObjectId, @@coll.insert('a' => 2)
    assert_kind_of BSON::ObjectId, @@coll.insert('b' => 3)

    assert_equal 3, @@coll.count
    docs = @@coll.find().to_a
    assert_equal 3, docs.length
    assert docs.detect { |row| row['a'] == 1 }
    assert docs.detect { |row| row['a'] == 2 }
    assert docs.detect { |row| row['b'] == 3 }

    @@coll << {'b' => 4}
    docs = @@coll.find().to_a
    assert_equal 4, docs.length
    assert docs.detect { |row| row['b'] == 4 }
  end

  def test_save_ordered_hash
    oh = BSON::OrderedHash.new
    oh['a'] = -1
    oh['b'] = 'foo'

    oid = @@coll.save(oh)
    assert_equal 'foo', @@coll.find_one(oid)['b']

    oh = BSON::OrderedHash['a' => 1, 'b' => 'foo']
    oid = @@coll.save(oh)
    assert_equal 'foo', @@coll.find_one(oid)['b']
  end

  def test_insert_multiple
    ids = @@coll.insert([{'a' => 2}, {'b' => 3}])

    ids.each do |i|
      assert_kind_of BSON::ObjectId, i
    end

    assert_equal 3, @@coll.count
    docs = @@coll.find().to_a
    assert_equal 3, docs.length
    assert docs.detect { |row| row['a'] == 1 }
    assert docs.detect { |row| row['a'] == 2 }
    assert docs.detect { |row| row['b'] == 3 }
  end

  def test_count_on_nonexisting
    @@db.drop_collection('foo')
    assert_equal 0, @@db.collection('foo').count()
  end

  def test_find_simple
    @r2 = @@coll.insert('a' => 2)
    @r3 = @@coll.insert('b' => 3)
    # Check sizes
    docs = @@coll.find().to_a
    assert_equal 3, docs.size
    assert_equal 3, @@coll.count

    # Find by other value
    docs = @@coll.find('a' => @r1['a']).to_a
    assert_equal 1, docs.size
    doc = docs.first
    # Can't compare _id values because at insert, an _id was added to @r1 by
    # the database but we don't know what it is without re-reading the record
    # (which is what we are doing right now).
#   assert_equal doc['_id'], @r1['_id']
    assert_equal doc['a'], @r1['a']
  end

  def test_find_advanced
    @@coll.insert('a' => 2)
    @@coll.insert('b' => 3)

    # Find by advanced query (less than)
    docs = @@coll.find('a' => { '$lt' => 10 }).to_a
    assert_equal 2, docs.size
    assert docs.detect { |row| row['a'] == 1 }
    assert docs.detect { |row| row['a'] == 2 }

    # Find by advanced query (greater than)
    docs = @@coll.find('a' => { '$gt' => 1 }).to_a
    assert_equal 1, docs.size
    assert docs.detect { |row| row['a'] == 2 }

    # Find by advanced query (less than or equal to)
    docs = @@coll.find('a' => { '$lte' => 1 }).to_a
    assert_equal 1, docs.size
    assert docs.detect { |row| row['a'] == 1 }

    # Find by advanced query (greater than or equal to)
    docs = @@coll.find('a' => { '$gte' => 1 }).to_a
    assert_equal 2, docs.size
    assert docs.detect { |row| row['a'] == 1 }
    assert docs.detect { |row| row['a'] == 2 }

    # Find by advanced query (between)
    docs = @@coll.find('a' => { '$gt' => 1, '$lt' => 3 }).to_a
    assert_equal 1, docs.size
    assert docs.detect { |row| row['a'] == 2 }

    # Find by advanced query (in clause)
    docs = @@coll.find('a' => {'$in' => [1,2]}).to_a
    assert_equal 2, docs.size
    assert docs.detect { |row| row['a'] == 1 }
    assert docs.detect { |row| row['a'] == 2 }
  end

  def test_find_sorting
    @@coll.remove
    @@coll.insert('a' => 1, 'b' => 2)
    @@coll.insert('a' => 2, 'b' => 1)
    @@coll.insert('a' => 3, 'b' => 2)
    @@coll.insert('a' => 4, 'b' => 1)

    # Sorting (ascending)
    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => [['a', 1]]).to_a
    assert_equal 4, docs.size
    assert_equal 1, docs[0]['a']
    assert_equal 2, docs[1]['a']
    assert_equal 3, docs[2]['a']
    assert_equal 4, docs[3]['a']

    # Sorting (descending)
    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => [['a', -1]]).to_a
    assert_equal 4, docs.size
    assert_equal 4, docs[0]['a']
    assert_equal 3, docs[1]['a']
    assert_equal 2, docs[2]['a']
    assert_equal 1, docs[3]['a']

    # Sorting using array of names; assumes ascending order.
    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => 'a').to_a
    assert_equal 4, docs.size
    assert_equal 1, docs[0]['a']
    assert_equal 2, docs[1]['a']
    assert_equal 3, docs[2]['a']
    assert_equal 4, docs[3]['a']

    # Sorting using single name; assumes ascending order.
    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => 'a').to_a
    assert_equal 4, docs.size
    assert_equal 1, docs[0]['a']
    assert_equal 2, docs[1]['a']
    assert_equal 3, docs[2]['a']
    assert_equal 4, docs[3]['a']

    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => [['b', 'asc'], ['a', 'asc']]).to_a
    assert_equal 4, docs.size
    assert_equal 2, docs[0]['a']
    assert_equal 4, docs[1]['a']
    assert_equal 1, docs[2]['a']
    assert_equal 3, docs[3]['a']

    # Sorting using empty array; no order guarantee should not blow up.
    docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => []).to_a
    assert_equal 4, docs.size

    # Sorting using ordered hash. You can use an unordered one, but then the
    # order of the keys won't be guaranteed thus your sort won't make sense.
    oh = BSON::OrderedHash.new
    oh['a'] = -1
    assert_raise InvalidSortValueError do 
      docs = @@coll.find({'a' => { '$lt' => 10 }}, :sort => oh).to_a
    end
  end

  def test_find_limits
    @@coll.insert('b' => 2)
    @@coll.insert('c' => 3)
    @@coll.insert('d' => 4)

    docs = @@coll.find({}, :limit => 1).to_a
    assert_equal 1, docs.size
    docs = @@coll.find({}, :limit => 2).to_a
    assert_equal 2, docs.size
    docs = @@coll.find({}, :limit => 3).to_a
    assert_equal 3, docs.size
    docs = @@coll.find({}, :limit => 4).to_a
    assert_equal 4, docs.size
    docs = @@coll.find({}).to_a
    assert_equal 4, docs.size
    docs = @@coll.find({}, :limit => 99).to_a
    assert_equal 4, docs.size
  end

  def test_find_one_no_records
    @@coll.remove
    x = @@coll.find_one('a' => 1)
    assert_nil x
  end

  def test_drop_collection
    assert @@db.drop_collection(@@coll.name), "drop of collection #{@@coll.name} failed"
    assert !@@db.collection_names.include?(@@coll.name)
  end

  def test_other_drop
    assert @@db.collection_names.include?(@@coll.name)
    @@coll.drop
    assert !@@db.collection_names.include?(@@coll.name)
  end

  def test_collection_names
    names = @@db.collection_names
    assert names.length >= 1
    assert names.include?(@@coll.name)

    coll2 = @@db.collection('test2')
    coll2.insert('a' => 1)      # collection not created until it's used
    names = @@db.collection_names
    assert names.length >= 2
    assert names.include?(@@coll.name)
    assert names.include?('mongo-ruby-test.test2')
  ensure
    @@db.drop_collection('test2')
  end

  def test_collections_info
    cursor = @@db.collections_info
    rows = cursor.to_a
    assert rows.length >= 1
    row = rows.detect { |r| r['name'] == @@coll_full_name }
    assert_not_nil row
  end

  def test_collection_options
    @@db.drop_collection('foobar')
    @@db.strict = true

    begin
      coll = @@db.create_collection('foobar', :capped => true, :size => 1024)
      options = coll.options()
      assert_equal 'foobar', options['create']
      assert_equal true, options['capped']
      assert_equal 1024, options['size']
    rescue => ex
      @@db.drop_collection('foobar')
      fail "did not expect exception \"#{ex}\""
    ensure
      @@db.strict = false
    end
  end

  def test_index_information
    assert_equal @@coll.index_information.length, 1

    name = @@coll.create_index('a')
    info = @@db.index_information(@@coll.name)
    assert_equal name, "a_1"
    assert_equal @@coll.index_information, info
    assert_equal 2, info.length

    assert info.has_key?(name)
    assert_equal info[name]["key"], {"a" => 1}
  ensure
    @@db.drop_index(@@coll.name, name)
  end

  def test_index_create_with_symbol
    assert_equal @@coll.index_information.length, 1

    name = @@coll.create_index([['a', 1]])
    info = @@db.index_information(@@coll.name)
    assert_equal name, "a_1"
    assert_equal @@coll.index_information, info
    assert_equal 2, info.length

    assert info.has_key?(name)
    assert_equal info[name]['key'], {"a" => 1}
  ensure
    @@db.drop_index(@@coll.name, name)
  end

  def test_multiple_index_cols
    name = @@coll.create_index([['a', DESCENDING], ['b', ASCENDING], ['c', DESCENDING]])
    info = @@db.index_information(@@coll.name)
    assert_equal 2, info.length

    assert_equal name, 'a_-1_b_1_c_-1'
    assert info.has_key?(name)
    assert_equal info[name]['key'], {"a" => -1, "b" => 1, "c" => -1}
  ensure
    @@db.drop_index(@@coll.name, name)
  end

  def test_multiple_index_cols_with_symbols
    name = @@coll.create_index([[:a, DESCENDING], [:b, ASCENDING], [:c, DESCENDING]])
    info = @@db.index_information(@@coll.name)
    assert_equal 2, info.length

    assert_equal name, 'a_-1_b_1_c_-1'
    assert info.has_key?(name)
    assert_equal info[name]['key'], {"a" => -1, "b" => 1, "c" => -1}
  ensure
    @@db.drop_index(@@coll.name, name)
  end

  def test_unique_index
    @@db.drop_collection("blah")
    test = @@db.collection("blah")
    test.create_index("hello")

    test.insert("hello" => "world")
    test.insert("hello" => "mike")
    test.insert("hello" => "world")
    assert !@@db.error?

    @@db.drop_collection("blah")
    test = @@db.collection("blah")
    test.create_index("hello", :unique => true)

    test.insert("hello" => "world")
    test.insert("hello" => "mike")
    test.insert("hello" => "world")
    assert @@db.error?
  end

  def test_index_on_subfield
    @@db.drop_collection("blah")
    test = @@db.collection("blah")

    test.insert("hello" => {"a" => 4, "b" => 5})
    test.insert("hello" => {"a" => 7, "b" => 2})
    test.insert("hello" => {"a" => 4, "b" => 10})
    assert !@@db.error?

    @@db.drop_collection("blah")
    test = @@db.collection("blah")
    test.create_index("hello.a", :unique => true)

    test.insert("hello" => {"a" => 4, "b" => 5})
    test.insert("hello" => {"a" => 7, "b" => 2})
    test.insert("hello" => {"a" => 4, "b" => 10})
    assert @@db.error?
  end

  def test_array
    @@coll << {'b' => [1, 2, 3]}
    rows = @@coll.find({}, {:fields => ['b']}).to_a
    if @@version < "1.1.3"
      assert_equal 1, rows.length
      assert_equal [1, 2, 3], rows[0]['b']
    else
      assert_equal 2, rows.length
      assert_equal [1, 2, 3], rows[1]['b']
    end
  end

  def test_regex
    regex = /foobar/i
    @@coll << {'b' => regex}
    rows = @@coll.find({}, {:fields => ['b']}).to_a
    if @@version < "1.1.3"
      assert_equal 1, rows.length
      assert_equal regex, rows[0]['b']
    else
      assert_equal 2, rows.length
      assert_equal regex, rows[1]['b']
    end
  end

  def test_non_oid_id
    # Note: can't use Time.new because that will include fractional seconds,
    # which Mongo does not store.
    t = Time.at(1234567890)
    @@coll << {'_id' => t}
    rows = @@coll.find({'_id' => t}).to_a
    assert_equal 1, rows.length
    assert_equal t, rows[0]['_id']
  end

  def test_strict
    assert !@@db.strict?
    @@db.strict = true
    assert @@db.strict?
  ensure
    @@db.strict = false
  end

  def test_strict_access_collection
    @@db.strict = true
    begin
      @@db.collection('does-not-exist')
      fail "expected exception"
    rescue => ex
      assert_equal Mongo::MongoDBError, ex.class
      assert_equal "Collection does-not-exist doesn't exist. Currently in strict mode.", ex.to_s
    ensure
      @@db.strict = false
      @@db.drop_collection('does-not-exist')
    end
  end

  def test_strict_create_collection
    @@db.drop_collection('foobar')
    @@db.strict = true

    begin
      @@db.create_collection('foobar')
      assert true
    rescue => ex
      fail "did not expect exception \"#{ex}\""
    end

    # Now the collection exists. This time we should see an exception.
    assert_raise Mongo::MongoDBError do
      @@db.create_collection('foobar')
    end
    @@db.strict = false
    @@db.drop_collection('foobar')

    # Now we're not in strict mode - should succeed
    @@db.create_collection('foobar')
    @@db.create_collection('foobar')
    @@db.drop_collection('foobar')
  end

  def test_where
    @@coll.insert('a' => 2)
    @@coll.insert('a' => 3)

    assert_equal 3, @@coll.count
    assert_equal 1, @@coll.find('$where' => BSON::Code.new('this.a > 2')).count()
    assert_equal 2, @@coll.find('$where' => BSON::Code.new('this.a > i', {'i' => 1})).count()
  end

  def test_eval
    assert_equal 3, @@db.eval('function (x) {return x;}', 3)

    assert_equal nil, @@db.eval("function (x) {db.test_eval.save({y:x});}", 5)
    assert_equal 5, @@db.collection('test_eval').find_one['y']

    assert_equal 5, @@db.eval("function (x, y) {return x + y;}", 2, 3)
    assert_equal 5, @@db.eval("function () {return 5;}")
    assert_equal 5, @@db.eval("2 + 3;")

    assert_equal 5, @@db.eval(Code.new("2 + 3;"))
    assert_equal 2, @@db.eval(Code.new("return i;", {"i" => 2}))
    assert_equal 5, @@db.eval(Code.new("i + 3;", {"i" => 2}))

    assert_raise OperationFailure do
      @@db.eval("5 ++ 5;")
    end
  end

  def test_hint
    name = @@coll.create_index('a')
    begin
      assert_nil @@coll.hint
      assert_equal 1, @@coll.find({'a' => 1}, :hint => 'a').to_a.size
      assert_equal 1, @@coll.find({'a' => 1}, :hint => ['a']).to_a.size
      assert_equal 1, @@coll.find({'a' => 1}, :hint => {'a' => 1}).to_a.size

      @@coll.hint = 'a'
      assert_equal({'a' => 1}, @@coll.hint)
      assert_equal 1, @@coll.find('a' => 1).to_a.size

      @@coll.hint = ['a']
      assert_equal({'a' => 1}, @@coll.hint)
      assert_equal 1, @@coll.find('a' => 1).to_a.size

      @@coll.hint = {'a' => 1}
      assert_equal({'a' => 1}, @@coll.hint)
      assert_equal 1, @@coll.find('a' => 1).to_a.size

      @@coll.hint = nil
      assert_nil @@coll.hint
      assert_equal 1, @@coll.find('a' => 1).to_a.size
    ensure
      @@coll.drop_index(name)
    end
  end

  def test_hash_default_value_id
    val = Hash.new(0)
    val["x"] = 5
    @@coll.insert val
    id = @@coll.find_one("x" => 5)["_id"]
    assert id != 0
  end

  def test_group
    @@db.drop_collection("test")
    test = @@db.collection("test")

    assert_equal [], test.group([], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }")
    assert_equal [], test.group([], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }")

    test.insert("a" => 2)
    test.insert("b" => 5)
    test.insert("a" => 1)

    assert_equal 3, test.group([], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }")[0]["count"]
    assert_equal 3, test.group([], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }")[0]["count"]
    assert_equal 1, test.group([], {"a" => {"$gt" => 1}}, {"count" => 0}, "function (obj, prev) { prev.count++; }")[0]["count"]
    assert_equal 1, test.group([], {"a" => {"$gt" => 1}}, {"count" => 0}, "function (obj, prev) { prev.count++; }")[0]["count"]

    finalize = "function (obj) { obj.f = obj.count - 1; }"
    assert_equal 2, test.group([], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }", finalize)[0]["f"]

    test.insert("a" => 2, "b" => 3)
    expected = [{"a" => 2, "count" => 2},
                {"a" => nil, "count" => 1},
                {"a" => 1, "count" => 1}]
    assert_equal expected, test.group(["a"], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }")
    assert_equal expected, test.group(["a"], {}, {"count" => 0}, "function (obj, prev) { prev.count++; }", true)

    assert_raise OperationFailure do
      test.group([], {}, {}, "5 ++ 5")
    end
    assert_raise OperationFailure do
      test.group([], {}, {}, "5 ++ 5", true)
    end
  end

  def test_deref
    @@coll.remove

    assert_equal nil, @@db.dereference(DBRef.new("test", ObjectId.new))
    @@coll.insert({"x" => "hello"})
    key = @@coll.find_one()["_id"]
    assert_equal "hello", @@db.dereference(DBRef.new("test", key))["x"]

    assert_equal nil, @@db.dereference(DBRef.new("test", 4))
    obj = {"_id" => 4}
    @@coll.insert(obj)
    assert_equal obj, @@db.dereference(DBRef.new("test", 4))

    @@coll.remove
    @@coll.insert({"x" => "hello"})
    assert_equal nil, @@db.dereference(DBRef.new("test", nil))
  end

  def test_save
    @@coll.remove

    a = {"hello" => "world"}

    id = @@coll.save(a)
    assert_kind_of ObjectId, id
    assert_equal 1, @@coll.count

    assert_equal id, @@coll.save(a)
    assert_equal 1, @@coll.count

    assert_equal "world", @@coll.find_one()["hello"]

    a["hello"] = "mike"
    @@coll.save(a)
    assert_equal 1, @@coll.count

    assert_equal "mike", @@coll.find_one()["hello"]

    @@coll.save({"hello" => "world"})
    assert_equal 2, @@coll.count
  end

  def test_save_long
    @@coll.remove
    @@coll.insert("x" => 9223372036854775807)
    assert_equal 9223372036854775807, @@coll.find_one()["x"]
  end

  def test_find_by_oid
    @@coll.remove

    @@coll.save("hello" => "mike")
    id = @@coll.save("hello" => "world")
    assert_kind_of ObjectId, id

    assert_equal "world", @@coll.find_one(:_id => id)["hello"]
    @@coll.find(:_id => id).to_a.each do |doc|
      assert_equal "world", doc["hello"]
    end

    id = ObjectId.from_string(id.to_s)
    assert_equal "world", @@coll.find_one(:_id => id)["hello"]
  end

  def test_save_with_object_that_has_id_but_does_not_actually_exist_in_collection
    @@coll.remove

    a = {'_id' => '1', 'hello' => 'world'}
    @@coll.save(a)
    assert_equal(1, @@coll.count)
    assert_equal("world", @@coll.find_one()["hello"])

    a["hello"] = "mike"
    @@coll.save(a)
    assert_equal(1, @@coll.count)
    assert_equal("mike", @@coll.find_one()["hello"])
  end

  if !RUBY_PLATFORM =~ /java/
  def test_invalid_key_names
    @@coll.remove

    @@coll.insert({"hello" => "world"})
    @@coll.insert({"hello" => {"hello" => "world"}})

    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"$hello" => "world"})
    end

    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hello" => {"$hello" => "world"}})
    end

    @@coll.insert({"he$llo" => "world"})
    @@coll.insert({"hello" => {"hell$o" => "world"}})

    assert_raise BSON::InvalidKeyName do
      @@coll.insert({".hello" => "world"})
    end
    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hello" => {".hello" => "world"}})
    end
    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hello." => "world"})
    end
    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hello" => {"hello." => "world"}})
    end
    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hel.lo" => "world"})
    end
    assert_raise BSON::InvalidKeyName do
      @@coll.insert({"hello" => {"hel.lo" => "world"}})
    end
  end
  end

  def test_collection_names
    assert_raise TypeError do
      @@db.collection(5)
    end
    assert_raise Mongo::InvalidNSName do
      @@db.collection("")
    end
    assert_raise Mongo::InvalidNSName do
      @@db.collection("te$t")
    end
    assert_raise Mongo::InvalidNSName do
      @@db.collection(".test")
    end
    assert_raise Mongo::InvalidNSName do
      @@db.collection("test.")
    end
    assert_raise Mongo::InvalidNSName do
      @@db.collection("tes..t")
    end
  end

  def test_rename_collection
    @@db.drop_collection("foo")
    @@db.drop_collection("bar")
    a = @@db.collection("foo")
    b = @@db.collection("bar")

    assert_raise TypeError do
      a.rename(5)
    end
    assert_raise Mongo::InvalidNSName do
      a.rename("")
    end
    assert_raise Mongo::InvalidNSName do
      a.rename("te$t")
    end
    assert_raise Mongo::InvalidNSName do
      a.rename(".test")
    end
    assert_raise Mongo::InvalidNSName do
      a.rename("test.")
    end
    assert_raise Mongo::InvalidNSName do
      a.rename("tes..t")
    end

    assert_equal 0, a.count()
    assert_equal 0, b.count()

    a.insert("x" => 1)
    a.insert("x" => 2)

    assert_equal 2, a.count()

    a.rename("bar")

    assert_equal 0, a.count()
    assert_equal 2, b.count()

    assert_equal 1, b.find().to_a()[0]["x"]
    assert_equal 2, b.find().to_a()[1]["x"]

    b.rename(:foo)

    assert_equal 2, a.count()
    assert_equal 0, b.count()
  end

  # doesn't really test functionality, just that the option is set correctly
  def test_snapshot
    @@db.collection("test").find({}, :snapshot => true).to_a
    assert_raise OperationFailure do
      @@db.collection("test").find({}, :snapshot => true, :sort => 'a').to_a
    end
  end

  def test_encodings
    if RUBY_VERSION >= '1.9'
      ascii = "hello world"
      utf8 = "hello world".encode("UTF-8")
      iso8859 = "hello world".encode("ISO-8859-1")

      assert_equal "US-ASCII", ascii.encoding.name
      assert_equal "UTF-8", utf8.encoding.name
      assert_equal "ISO-8859-1", iso8859.encoding.name

      @@coll.remove
      @@coll.save("ascii" => ascii, "utf8" => utf8, "iso8859" => iso8859)
      doc = @@coll.find_one()

      assert_equal "UTF-8", doc["ascii"].encoding.name
      assert_equal "UTF-8", doc["utf8"].encoding.name
      assert_equal "UTF-8", doc["iso8859"].encoding.name
    end
  end
end
