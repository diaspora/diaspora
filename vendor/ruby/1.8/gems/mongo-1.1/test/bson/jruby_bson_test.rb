# encoding:utf-8
require './test/test_helper'

# Special tests for the JRuby encoder only
if RUBY_PLATFORM =~ /java/

class JRubyBSONTest < Test::Unit::TestCase
  include BSON

  def setup
    @encoder = BSON::BSON_CODER
    @decoder = BSON::BSON_RUBY
  end

  def test_object_id
    oid = {'doc' => BSON::ObjectId.new}
    p oid['doc'].data
    bson = @encoder.serialize(oid)
    assert_equal oid, @encoder.deserialize(bson)
  end

end

end
