require './test/test_helper'
require 'rubygems'
require 'json'

class JSONTest < Test::Unit::TestCase

  include Mongo
  include BSON

  def test_object_id_as_json
    id = ObjectId.new
    obj = {'_id' => id}
    assert_equal "{\"_id\":{\"$oid\": \"#{id.to_s}\"}}", obj.to_json
  end

end
