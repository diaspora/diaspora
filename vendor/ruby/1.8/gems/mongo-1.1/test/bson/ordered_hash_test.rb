require './test/test_helper'

class OrderedHashTest < Test::Unit::TestCase

  def setup
    @oh = BSON::OrderedHash.new
    @oh['c'] = 1
    @oh['a'] = 2
    @oh['z'] = 3
    @ordered_keys = %w(c a z)
  end

  def test_initialize
    a = BSON::OrderedHash.new
    a['x'] = 1
    a['y'] = 2

    b = BSON::OrderedHash['x' => 1, 'y' => 2]
    assert_equal a, b
  end

  def test_hash_code
    o = BSON::OrderedHash.new
    o['number'] = 50
    assert o.hash
  end

  def test_empty
    assert_equal [], BSON::OrderedHash.new.keys
  end

  def test_uniq
    list = []
    doc  = BSON::OrderedHash.new
    doc['_id']  = 'ab12'
    doc['name'] = 'test'

    same_doc = BSON::OrderedHash.new
    same_doc['_id']  = 'ab12'
    same_doc['name'] = 'test'
    list << doc
    list << same_doc

    assert_equal 2, list.size
    assert_equal 1, list.uniq.size
  end

  def test_equality
    a = BSON::OrderedHash.new
    a['x'] = 1
    a['y'] = 2

    b = BSON::OrderedHash.new
    b['y'] = 2
    b['x'] = 1

    c = BSON::OrderedHash.new
    c['x'] = 1
    c['y'] = 2

    d = BSON::OrderedHash.new
    d['x'] = 2
    d['y'] = 3

    e = BSON::OrderedHash.new
    e['z'] = 1
    e['y'] = 2

    assert_equal a, c
    assert_not_equal a, b
    assert_not_equal a, d
    assert_not_equal a, e
  end

  def test_order_preserved
    assert_equal @ordered_keys, @oh.keys
  end

  def test_to_a_order_preserved
    assert_equal @ordered_keys, @oh.to_a.map {|m| m.first}
  end

  def test_order_preserved_after_replace
    @oh['a'] = 42
    assert_equal @ordered_keys, @oh.keys
    @oh['c'] = 'foobar'
    assert_equal @ordered_keys, @oh.keys
    @oh['z'] = /huh?/
    assert_equal @ordered_keys, @oh.keys
  end

  def test_each
    keys = []
    @oh.each { |k, v| keys << k }
    assert_equal keys, @oh.keys

    @oh['z'] = 42
    assert_equal keys, @oh.keys

    assert_equal @oh, @oh.each {|k,v|}
  end

  def test_values
    assert_equal [1, 2, 3], @oh.values
  end

  def test_merge
    other = BSON::OrderedHash.new
    other['f'] = 'foo'
    noob = @oh.merge(other)
    assert_equal @ordered_keys + ['f'], noob.keys
    assert_equal [1, 2, 3, 'foo'], noob.values
  end

  def test_merge_bang
    other = BSON::OrderedHash.new
    other['f'] = 'foo'
    @oh.merge!(other)
    assert_equal @ordered_keys + ['f'], @oh.keys
    assert_equal [1, 2, 3, 'foo'], @oh.values
  end

  def test_merge_bang_with_overlap
    other = BSON::OrderedHash.new
    other['a'] = 'apple'
    other['c'] = 'crab'
    other['f'] = 'foo'
    @oh.merge!(other)
    assert_equal @ordered_keys + ['f'], @oh.keys
    assert_equal ['crab', 'apple', 3, 'foo'], @oh.values
  end

  def test_merge_bang_with_hash_with_overlap
    other = Hash.new
    other['a'] = 'apple'
    other['c'] = 'crab'
    other['f'] = 'foo'
    @oh.merge!(other)
    assert_equal @ordered_keys + ['f'], @oh.keys
    assert_equal ['crab', 'apple', 3, 'foo'], @oh.values
  end

  def test_equality_with_hash
    o = BSON::OrderedHash.new
    o[:a] = 1
    o[:b] = 2
    o[:c] = 3
    r = {:a => 1, :b => 2, :c => 3}
    assert r == o
    assert o == r
  end

  def test_update
    other = BSON::OrderedHash.new
    other['f'] = 'foo'
    noob = @oh.update(other)
    assert_equal @ordered_keys + ['f'], noob.keys
    assert_equal [1, 2, 3, 'foo'], noob.values
  end

  def test_inspect_retains_order
    assert_equal '{"c"=>1, "a"=>2, "z"=>3}', @oh.inspect
  end

  def test_clear
    @oh.clear
    assert @oh.keys.empty?
  end

  def test_delete
    assert @oh.keys.include?('z')
    @oh.delete('z')
    assert !@oh.keys.include?('z')
  end

  def test_delete_if
    assert @oh.keys.include?('z')
    @oh.delete_if { |k,v| k == 'z' }
    assert !@oh.keys.include?('z')
  end

  def test_reject
    new = @oh.reject { |k, v| k == 'foo' }
    assert new.keys == @oh.keys

    new = @oh.reject { |k, v| k == 'z' }
    assert !new.keys.include?('z')
  end

  def test_clone
    copy = @oh.clone
    assert copy.keys == @oh.keys

    copy[:foo] = 1
    assert copy.keys != @oh.keys
  end
end
