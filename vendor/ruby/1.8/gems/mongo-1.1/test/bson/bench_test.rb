# encoding:utf-8
require './test/test_helper'
require 'complex'
require 'bigdecimal'
require 'rational'
require 'benchmark'

MEDIUM = {
  'integer' => 5,
  'number' => 5.05,
  'boolean' => false,
  'array' => ['test', 'benchmark']
}


LARGE = {
  'base_url' => 'http://www.example.com/test-me',
  'total_word_count' => 6743,
  'access_time' => 1,# Time.now,
  'meta_tags' => {
    'description' => 'i am a long description string',
    'author' => 'Holly Man',
    'dynamically_created_meta_tag' => 'who know\n what'
  },
  'page_structure' => {
    'counted_tags' => 3450,
    'no_of_js_attached' => 10,
    'no_of_images' => 6
  },
  'harvested_words' => ['10gen','web','open','source','application','paas',
                        'platform-as-a-service','technology','helps',
                        'developers','focus','building','mongodb','mongo'] * 20
}



begin
  require 'active_support/core_ext'
  require 'active_support/hash_with_indifferent_access'
  Time.zone = "Pacific Time (US & Canada)"
  Zone = Time.zone.now
rescue LoadError
  warn 'Could not test BSON with HashWithIndifferentAccess.'
  module ActiveSupport
    class TimeWithZone
    end
  end
  Zone = ActiveSupport::TimeWithZone.new
end

class BSONTest < Test::Unit::TestCase
  include BSON

  def setup
    @encoder = BSON::BSON_RUBY
    @decoder = BSON::BSON_RUBY
    @con = Mongo::Connection.new
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

#  def test_bench_big_string
#    t0 = Time.now
#    @con['foo']['bar'].remove
#    doc = {'doc' => 'f' * 2_000_000}
#    10.times do
#      @con['foo']['bar'].save({'d' => doc})
#      @con['foo']['bar'].find.to_a
#    end
#    puts "Big String"
#    puts Time.now - t0
#  end
#
#  def test_big_array
#    t0 = Time.now
#    @con['foo']['bar'].remove
#    doc = {'doc' => 'f' * 2_000_000}
#    10.times do
#      @con['foo']['bar'].save({'d' => doc})
#      @con['foo']['bar'].find.to_a
#    end
#    puts "Big String"
#    puts Time.now - t0
#  end
#
#  def test_string
#    doc = {'doc' => "Hello world!", 'awesome' => true, 'a' => 1, 'b' => 4_333_433_232, 'c' => 2.33, 'd' => nil,
#    'f' => BSON::Code.new("function"), 'g' => BSON::ObjectId.new, 'h' => [1, 2, 3]}
#    bson = @encoder.serialize(doc)
#    d = @encoder.deserialize(bson)
#    puts "Array"
#    puts d
#    puts d['h']
#    puts "End Array"
#    puts d['h'][0]
#    puts d['h'][1]
#    puts (d['h'][2] + 100).class
#    puts "ObjecId Info"
#    bson2 = @encoder.serialize(d)
#    doc2 = @encoder.deserialize(bson2)
#    assert_equal doc2, @encoder.deserialize(bson)
#  end
#

  def test_eval
    code = BSON::Code.new('f')
    oh = BSON::OrderedHash.new
    oh[:$eval] = code
    oh[:args]  = [1]

    assert_equal BSON::BSON_RUBY.serialize(oh).to_a, BSON::BSON_JAVA.serialize(oh).to_a
    assert_equal 3, @con['admin'].eval('function (x) {return x;}', 3)
  end

#  def test_oid
#    b = Java::OrgBsonTypes::ObjectId.new.toByteArray
#    o = ObjectId.new(b)
#    p o
#  end
#
  def test_speed
    @con['foo']['bar'].remove

    puts "Test OID"
    t0 = Time.now
    5000.times do
      ids = [BSON::ObjectId.new] * 1000
      @encoder.serialize({'doc' => BSON::ObjectId.new})
    end
    puts Time.now - t0

    puts "Decode OID"
    ids = [BSON::ObjectId.new] * 1000
    doc = {'doc' => ids}
    bson = @encoder.serialize(doc)
    t0 = Time.now
    50.times do
      @encoder.deserialize(bson)
    end
    puts Time.now - t0


    puts "Test insert"
    t0 = Time.now
    1000.times do |n|
      if n % 1000 == 0
        puts Time.now - t0
        t0 = Time.now
      end
      @con['foo']['bar'].insert({'doc' => MEDIUM})
    end
    puts Time.now - t0

    puts "Test query / deserialize"
    t0 = Time.now
    @con['foo']['bar'].find.to_a
    t1 = Time.now
    puts t1 - t0
  end


end
