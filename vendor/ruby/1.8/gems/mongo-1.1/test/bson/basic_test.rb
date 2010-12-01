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
  'access_time' => Time.now,
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

  def test_string
    doc = {'doc' => 'hello, world'}
    bson = bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_object
    doc = {'doc' => {'age' => 42, 'name' => 'Spongebob', 'shoe_size' => 9.5}}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_oid
    doc = {'doc' => ObjectID.new}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_array
    doc = {'doc' => [1, 2, "a", "b"]}
    bson = BSON::BSON_CODER.serialize(doc)
    assert_equal doc, BSON::BSON_CODER.deserialize(bson)
  end

  def test_speed

  Benchmark.bm do |x|
    x.report('serialize obj') do
      1000.times do
        BSON::BSON_CODER.serialize(LARGE)
      end
    end
  end



  Benchmark.bm do |x|
        b = BSON::BSON_CODER.serialize(LARGE)
    x.report('deserialize obj') do
      1000.times do
        BSON::BSON_CODER.deserialize(b)
      end
    end
  end
  end
end
