# encoding:utf-8
require './test/test_helper'
require 'complex'
require 'bigdecimal'
require 'rational'

begin
  require 'active_support/core_ext'
  Time.zone = "Pacific Time (US & Canada)"
  Zone = Time.zone.now
rescue LoadError
  warn 'Mocking time with zone'
  module ActiveSupport
    class TimeWithZone
    end
  end
  Zone = ActiveSupport::TimeWithZone.new
end

class BSONTest < Test::Unit::TestCase

  include BSON

  # This setup allows us to change the decoders for
  # cross-coder compatibility testing
  def setup
    @encoder = BSON::BSON_CODER
    @decoder = @encoder
  end

  def assert_doc_pass(doc, options={})
    bson = @encoder.serialize(doc)
    if options[:debug]
      puts "DEBUGGIN DOC:"
      p bson.to_a
      puts "DESERIALIZES TO:"
      p @decoder.deserialize(bson)
    end
    assert_equal @decoder.serialize(doc).to_a, bson.to_a
    assert_equal doc, @decoder.deserialize(bson)
  end

  def test_require_hash
    assert_raise_error InvalidDocument, "takes a Hash" do
      BSON.serialize('foo')
    end

    assert_raise_error InvalidDocument, "takes a Hash" do
      BSON.serialize(Object.new)
    end

    assert_raise_error InvalidDocument, "takes a Hash" do
      BSON.serialize(Set.new)
    end
  end

  def test_string
    doc = {'doc' => 'hello, world'}
    assert_doc_pass(doc)
  end

  def test_valid_utf8_string
    doc = {'doc' => 'aé'}
    assert_doc_pass(doc)
  end

  def test_valid_utf8_key
    doc = {'aé' => 'hello'}
    assert_doc_pass(doc)
  end

  def test_document_length
    doc = {'name' => 'a' * 5 * 1024 * 1024}
    assert_raise InvalidDocument do
      assert @encoder.serialize(doc)
    end
  end

  # In 1.8 we test that other string encodings raise an exception.
  # In 1.9 we test that they get auto-converted.
  if RUBY_VERSION < '1.9'
    require 'iconv'
    def test_invalid_string
      string = Iconv.conv('iso-8859-1', 'utf-8', 'aé')
      doc = {'doc' => string}
      assert_raise InvalidStringEncoding do
        @encoder.serialize(doc)
      end
    end

    def test_invalid_key
      key = Iconv.conv('iso-8859-1', 'utf-8', 'aé')
      doc = {key => 'hello'}
      assert_raise InvalidStringEncoding do
        @encoder.serialize(doc)
      end
    end
  else
    def test_non_utf8_string
      bson = BSON::BSON_CODER.serialize({'str' => 'aé'.encode('iso-8859-1')})
      result = BSON::BSON_CODER.deserialize(bson)['str']
      assert_equal 'aé', result
      assert_equal 'UTF-8', result.encoding.name
    end

    def test_non_utf8_key
      bson = BSON::BSON_CODER.serialize({'aé'.encode('iso-8859-1') => 'hello'})
      assert_equal 'hello', BSON::BSON_CODER.deserialize(bson)['aé']
    end

    # Based on a test from sqlite3-ruby
    def test_default_internal_is_honored
      before_enc = Encoding.default_internal

      str = "壁に耳あり、障子に目あり"
      bson = BSON::BSON_CODER.serialize("x" => str)

      Encoding.default_internal = 'EUC-JP'
      out = BSON::BSON_CODER.deserialize(bson)["x"]

      assert_equal Encoding.default_internal, out.encoding
      assert_equal str.encode('EUC-JP'), out
      assert_equal str, out.encode(str.encoding)
    ensure
      Encoding.default_internal = before_enc
    end
  end

  def test_code
    doc = {'$where' => Code.new('this.a.b < this.b')}
    assert_doc_pass(doc)
  end

  def test_code_with_scope
    doc = {'$where' => Code.new('this.a.b < this.b', {'foo' => 1})}
    assert_doc_pass(doc)
  end

   def test_double
     doc = {'doc' => 41.25}
     assert_doc_pass(doc)
   end

 def test_int
    doc = {'doc' => 42}
    assert_doc_pass(doc)

    doc = {"doc" => -5600}
    assert_doc_pass(doc)

    doc = {"doc" => 2147483647}
    assert_doc_pass(doc)

    doc = {"doc" => -2147483648}
    assert_doc_pass(doc)
  end

  def test_ordered_hash
    doc = BSON::OrderedHash.new
    doc["b"] = 1
    doc["a"] = 2
    doc["c"] = 3
    doc["d"] = 4
    assert_doc_pass(doc)
  end

  def test_object
    doc = {'doc' => {'age' => 42, 'name' => 'Spongebob', 'shoe_size' => 9.5}}
    assert_doc_pass(doc)
    bson = BSON::BSON_CODER.serialize(doc)
  end

  def test_oid
    doc = {'doc' => ObjectId.new}
    assert_doc_pass(doc)
  end

  def test_array
    doc = {'doc' => [1, 2, 'a', 'b']}
    assert_doc_pass(doc)
  end

  def test_regex
    doc = {'doc' => /foobar/i}
    assert_doc_pass(doc)
  end

  def test_boolean
    doc = {'doc' => true}
    assert_doc_pass(doc)
  end

  def test_date
    doc = {'date' => Time.now}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    # Mongo only stores up to the millisecond
    assert_in_delta doc['date'], doc2['date'], 0.001
  end

  def test_date_returns_as_utc
    doc = {'date' => Time.now}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    assert doc2['date'].utc?
  end

  def test_date_before_epoch
    begin
      doc = {'date' => Time.utc(1600)}
      bson = @encoder.serialize(doc)
      doc2 = @decoder.deserialize(bson)
      # Mongo only stores up to the millisecond
      assert_in_delta doc['date'], doc2['date'], 2
    rescue ArgumentError
      # some versions of Ruby won't let you create pre-epoch Time instances
      #
      # TODO figure out how that will work if somebady has saved data
      # w/ early dates already and is just querying for it.
    end
  end

  def test_exeption_on_using_unsupported_date_class
    [DateTime.now, Date.today, Zone].each do |invalid_date|
      doc = {:date => invalid_date}
      begin
      bson = BSON::BSON_CODER.serialize(doc)
      rescue => e
      ensure
        if !invalid_date.is_a? Time
          assert_equal InvalidDocument, e.class
          assert_match /UTC Time/, e.message
        end
      end
    end
  end

  def test_dbref
    oid = ObjectId.new
    doc = {}
    doc['dbref'] = DBRef.new('namespace', oid)
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)

    # Java doesn't deserialize to DBRefs
    if RUBY_PLATFORM =~ /java/
      assert_equal 'namespace', doc2['dbref']['$ns']
      assert_equal oid, doc2['dbref']['$id']
    else
      assert_equal 'namespace', doc2['dbref'].namespace
      assert_equal oid, doc2['dbref'].object_id
    end
  end

  def test_symbol
    doc = {'sym' => :foo}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    assert_equal :foo, doc2['sym']
  end

  def test_binary
    bin = Binary.new
    'binstring'.each_byte { |b| bin.put(b) }

    doc = {'bin' => bin}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    bin2 = doc2['bin']
    assert_kind_of Binary, bin2
    assert_equal 'binstring', bin2.to_s
    assert_equal Binary::SUBTYPE_BYTES, bin2.subtype
  end

  def test_binary_with_string
    b = Binary.new('somebinarystring')
    doc = {'bin' => b}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    bin2 = doc2['bin']
    assert_kind_of Binary, bin2
    assert_equal 'somebinarystring', bin2.to_s
    assert_equal Binary::SUBTYPE_BYTES, bin2.subtype
  end

  def test_binary_type
    bin = Binary.new([1, 2, 3, 4, 5], Binary::SUBTYPE_USER_DEFINED)

    doc = {'bin' => bin}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    bin2 = doc2['bin']
    assert_kind_of Binary, bin2
    assert_equal [1, 2, 3, 4, 5], bin2.to_a
    assert_equal Binary::SUBTYPE_USER_DEFINED, bin2.subtype
  end

  # Java doesn't support binary subtype 0 yet
  if !(RUBY_PLATFORM =~ /java/)
    def test_binary_subtype_0
      bin = Binary.new([1, 2, 3, 4, 5], Binary::SUBTYPE_SIMPLE)

      doc = {'bin' => bin}
      bson = @encoder.serialize(doc)
      doc2 = @decoder.deserialize(bson)
      bin2 = doc2['bin']
      assert_kind_of Binary, bin2
      assert_equal [1, 2, 3, 4, 5], bin2.to_a
      assert_equal Binary::SUBTYPE_SIMPLE, bin2.subtype
    end
  end

  def test_binary_byte_buffer
    bb = Binary.new
    5.times { |i| bb.put(i + 1) }

    doc = {'bin' => bb}
    bson = @encoder.serialize(doc)
    doc2 = @decoder.deserialize(bson)
    bin2 = doc2['bin']
    assert_kind_of Binary, bin2
    assert_equal [1, 2, 3, 4, 5], bin2.to_a
    assert_equal Binary::SUBTYPE_BYTES, bin2.subtype
  end

  def test_put_id_first
    val = BSON::OrderedHash.new
    val['not_id'] = 1
    val['_id'] = 2
    roundtrip = @decoder.deserialize(@encoder.serialize(val, false, true).to_s)
    assert_kind_of BSON::OrderedHash, roundtrip
    assert_equal '_id', roundtrip.keys.first

    val = {'a' => 'foo', 'b' => 'bar', :_id => 42, 'z' => 'hello'}
    roundtrip = @decoder.deserialize(@encoder.serialize(val, false, true).to_s)
    assert_kind_of BSON::OrderedHash, roundtrip
    assert_equal '_id', roundtrip.keys.first
  end

  def test_nil_id
    doc = {"_id" => nil}
    assert_doc_pass(doc)
  end

  if !(RUBY_PLATFORM =~ /java/)
    def test_timestamp
      val = {"test" => [4, 20]}
      assert_equal val, @decoder.deserialize([0x13, 0x00, 0x00, 0x00,
                                        0x11, 0x74, 0x65, 0x73,
                                        0x74, 0x00, 0x04, 0x00,
                                        0x00, 0x00, 0x14, 0x00,
                                        0x00, 0x00, 0x00])

    end
  end

  def test_overflow
    doc = {"x" => 2**75}
    assert_raise RangeError do
      bson = @encoder.serialize(doc)
    end

    doc = {"x" => 9223372036854775}
    assert_doc_pass(doc)

    doc = {"x" => 9223372036854775807}
    assert_doc_pass(doc)

    doc["x"] = doc["x"] + 1
    assert_raise RangeError do
      bson = @encoder.serialize(doc)
    end

    doc = {"x" => -9223372036854775}
    assert_doc_pass(doc)

    doc = {"x" => -9223372036854775808}
    assert_doc_pass(doc)

    doc["x"] = doc["x"] - 1
    assert_raise RangeError do
      bson = BSON::BSON_CODER.serialize(doc)
    end
  end

  def test_invalid_numeric_types
    [BigDecimal.new("1.0"), Complex(0, 1), Rational(2, 3)].each do |type|
      doc = {"x" => type}
      begin
        @encoder.serialize(doc)
      rescue => e
      ensure
        assert_equal InvalidDocument, e.class
        assert_match /Cannot serialize/, e.message
      end
    end
  end

  def test_do_not_change_original_object
    val = BSON::OrderedHash.new
    val['not_id'] = 1
    val['_id'] = 2
    assert val.keys.include?('_id')
    @encoder.serialize(val)
    assert val.keys.include?('_id')

    val = {'a' => 'foo', 'b' => 'bar', :_id => 42, 'z' => 'hello'}
    assert val.keys.include?(:_id)
    @encoder.serialize(val)
    assert val.keys.include?(:_id)
  end

  # note we only test for _id here because in the general case we will
  # write duplicates for :key and "key". _id is a special case because
  # we call has_key? to check for it's existence rather than just iterating
  # over it like we do for the rest of the keys. thus, things like
  # HashWithIndifferentAccess can cause problems for _id but not for other
  # keys. rather than require rails to test with HWIA directly, we do this
  # somewhat hacky test.
  def test_no_duplicate_id
    dup = {"_id" => "foo", :_id => "foo"}
    one = {"_id" => "foo"}

    assert_equal @encoder.serialize(one).to_a, @encoder.serialize(dup).to_a
  end

  def test_no_duplicate_id_when_moving_id
    dup = {"_id" => "foo", :_id => "foo"}
    one = {:_id => "foo"}

    assert_equal @encoder.serialize(one, false, true).to_s, @encoder.serialize(dup, false, true).to_s
  end

  def test_null_character
    doc = {"a" => "\x00"}

    assert_doc_pass(doc)

    assert_raise InvalidDocument do
      @encoder.serialize({"\x00" => "a"})
    end

    assert_raise InvalidDocument do
      @encoder.serialize({"a" => (Regexp.compile "ab\x00c")})
    end
  end

  def test_max_key
    doc = {"a" => MaxKey.new}
    assert_doc_pass(doc)
  end

  def test_min_key
    doc = {"a" => MinKey.new}
    assert_doc_pass(doc)
  end

  def test_invalid_object
    o = Object.new
    assert_raise InvalidDocument do
      @encoder.serialize({:foo => o})
    end

    assert_raise InvalidDocument do
      @encoder.serialize({:foo => Date.today})
    end
  end

  def test_move_id
    a = BSON::OrderedHash.new
    a['text'] = 'abc'
    a['key'] = 'abc'
    a['_id']  = 1


    assert_equal ")\000\000\000\020_id\000\001\000\000\000\002text" +
                 "\000\004\000\000\000abc\000\002key\000\004\000\000\000abc\000\000",
                 @encoder.serialize(a, false, true).to_s

    # Java doesn't support this. Isn't actually necessary.
    if !(RUBY_PLATFORM =~ /java/)
      assert_equal ")\000\000\000\002text\000\004\000\000\000abc\000\002key" +
                   "\000\004\000\000\000abc\000\020_id\000\001\000\000\000\000",
                   @encoder.serialize(a, false, false).to_s
    end
  end

  def test_move_id_with_nested_doc
    b = BSON::OrderedHash.new
    b['text'] = 'abc'
    b['_id']   = 2
    c = BSON::OrderedHash.new
    c['text'] = 'abc'
    c['hash'] = b
    c['_id']  = 3
    assert_equal ">\000\000\000\020_id\000\003\000\000\000\002text" +
                 "\000\004\000\000\000abc\000\003hash\000\034\000\000" +
                 "\000\002text\000\004\000\000\000abc\000\020_id\000\002\000\000\000\000\000",
                 @encoder.serialize(c, false, true).to_s

    # Java doesn't support this. Isn't actually necessary.
    if !(RUBY_PLATFORM =~ /java/)
      assert_equal ">\000\000\000\002text\000\004\000\000\000abc\000\003hash" +
                   "\000\034\000\000\000\002text\000\004\000\000\000abc\000\020_id" +
                   "\000\002\000\000\000\000\020_id\000\003\000\000\000\000",
                   @encoder.serialize(c, false, false).to_s
    end
  end

  # Mocking this class for testing
  class ::HashWithIndifferentAccess < Hash; end

  def test_keep_id_with_hash_with_indifferent_access
    doc = HashWithIndifferentAccess.new
    embedded = HashWithIndifferentAccess.new
    embedded['_id'] = ObjectId.new
    doc['_id']      = ObjectId.new
    doc['embedded'] = [embedded]
    @encoder.serialize(doc, false, true).to_a
    assert doc.has_key?("_id")
    assert doc['embedded'][0].has_key?("_id")

    doc['_id'] = ObjectId.new
    @encoder.serialize(doc, false, true).to_a
    assert doc.has_key?("_id")
  end

end
