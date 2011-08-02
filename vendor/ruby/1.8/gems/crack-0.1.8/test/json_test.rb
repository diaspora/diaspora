# coding: utf-8
require 'test_helper'

class JsonTest < Test::Unit::TestCase  
  TESTS = {
    %q({"data": "G\u00fcnter"})                   => {"data" => "Günter"},
    %q({"returnTo":{"\/categories":"\/"}})        => {"returnTo" => {"/categories" => "/"}},
    %q({returnTo:{"\/categories":"\/"}})          => {"returnTo" => {"/categories" => "/"}},
    %q({"return\\"To\\":":{"\/categories":"\/"}}) => {"return\"To\":" => {"/categories" => "/"}},
    %q({"returnTo":{"\/categories":1}})           => {"returnTo" => {"/categories" => 1}},
    %({"returnTo":[1,"a"]})                       => {"returnTo" => [1, "a"]},
    %({"returnTo":[1,"\\"a\\",", "b"]})           => {"returnTo" => [1, "\"a\",", "b"]},
    %({a: "'", "b": "5,000"})                     => {"a" => "'", "b" => "5,000"},
    %({a: "a's, b's and c's", "b": "5,000"})      => {"a" => "a's, b's and c's", "b" => "5,000"},
    %({a: "2007-01-01"})                          => {'a' => Date.new(2007, 1, 1)}, 
    %({a: "2007-01-01 01:12:34 Z"})               => {'a' => Time.utc(2007, 1, 1, 1, 12, 34)}, 
    # Handle ISO 8601 date/time format http://en.wikipedia.org/wiki/ISO_8601
    %({a: "2007-01-01T01:12:34Z"})                => {'a' => Time.utc(2007, 1, 1, 1, 12, 34)},
    # no time zone
    %({a: "2007-01-01 01:12:34"})                 => {'a' => "2007-01-01 01:12:34"},
    %({"bio": "1985-01-29: birthdate"})           => {'bio' => '1985-01-29: birthdate'},
    %([])    => [],
    %({})    => {},
    %(1)     => 1,
    %("")    => "",
    %("\\"") => "\"",
    %(null)  => nil,
    %(true)  => true,
    %(false) => false,
    %q("http:\/\/test.host\/posts\/1") => "http://test.host/posts/1"
  }
  
  TESTS.each do |json, expected|
    should "should decode json (#{json})" do
      lambda {
        Crack::JSON.parse(json).should == expected
      }.should_not raise_error
    end
  end

  should "should raise error for failed decoding" do
    lambda {
      Crack::JSON.parse(%({: 1}))
    }.should raise_error(Crack::ParseError)
  end
  
  should "should be able to parse a JSON response from a Twitter search about 'firefox'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-firefox.json", "r") { |f|
        data = f.read
    }
    
    lambda {
      Crack::JSON.parse(data)
    }.should_not raise_error(Crack::ParseError)
  end

  should "should be able to parse a JSON response from a Twitter search about 'internet explorer'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-ie.json", "r") { |f|
        data = f.read
    }
    
    lambda {
      Crack::JSON.parse(data)
    }.should_not raise_error(Crack::ParseError)
  end

end
