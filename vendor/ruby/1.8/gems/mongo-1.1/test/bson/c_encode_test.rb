# encoding:utf-8
require 'test/test_helper'
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
  'access_time' => 123, #Time.now,
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

class CBSONTest < Test::Unit::TestCase
  include BSON

  def setup
    @encoder = BSON::BSON_CODER
  end

  def test_nested_string
    t0 = Time.now
    50000.times do
      @encoder.serialize({'doc' => MEDIUM})
    end
    t1 = Time.now
    puts t1 - t0
  end

end
