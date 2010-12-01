#!/usr/bin/env ruby

$LOAD_PATH[0,0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongo'

include Mongo

TRIALS = 100000

def encode(doc)
  t0 = Time.new
  b = Mongo::BSON_CODER.new
  TRIALS.times { |i|
    b = Mongo::BSON_CODER.new
    b.serialize doc
  }
  print "took: #{Time.now.to_f - t0.to_f}\n"
  return b
end

def decode(bson)
  t0 = Time.new
  doc = nil
  TRIALS.times { |i|
    doc = bson.deserialize
  }
  print "took: #{Time.now.to_f - t0.to_f}\n"
  return doc
end

TEST_CASES = [{},
              {
                "hello" => "world"
              },
              {
                "hello" => "world",
                "mike" => "something",
                "here's" => "another"
              },
              {
                "int" => 200,
                "bool" => true,
                "an int" => 20,
                "a bool" => false
              },
              {
                "this" => 5,
                "is" => {"a" => true},
                "big" => [true, 5.5],
                "object" => nil
              }]

TEST_CASES.each { |doc|
  print "case #{doc.inspect}\n"
  print "enc bson\n"
  enc_bson = encode(doc)
  print "dec bson\n"
  raise "FAIL" unless doc == decode(enc_bson)
}
