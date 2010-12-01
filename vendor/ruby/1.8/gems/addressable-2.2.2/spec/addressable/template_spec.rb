# encoding:utf-8
#--
# Addressable, Copyright (c) 2006-2007 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "addressable/template"

if !"".respond_to?("force_encoding")
  class String
    def force_encoding(encoding)
      @encoding = encoding
    end

    def encoding
      @encoding ||= Encoding::ASCII_8BIT
    end
  end

  class Encoding
    def initialize(name)
      @name = name
    end

    def to_s
      return @name
    end

    UTF_8 = Encoding.new("UTF-8")
    ASCII_8BIT = Encoding.new("US-ASCII")
  end
end

class ExampleProcessor
  def self.validate(name, value)
    return !!(value =~ /^[\w ]+$/) if name == "query"
    return true
  end

  def self.transform(name, value)
    return value.gsub(/ /, "+") if name == "query"
    return value
  end

  def self.restore(name, value)
    return value.gsub(/\+/, " ") if name == "query"
    return value.tr("A-Za-z", "N-ZA-Mn-za-m") if name == "rot13"
    return value
  end

  def self.match(name)
    return ".*?" if name == "first"
    return ".*"
  end
end

class SlashlessProcessor
  def self.match(name)
    return "[^/\\n]*"
  end
end

class NoOpProcessor
  def self.transform(name, value)
    value
  end
end

describe Addressable::Template do
  it "should raise a TypeError for invalid patterns" do
    (lambda do
      Addressable::Template.new(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into String.")
  end
end

describe Addressable::Template, "created with the pattern '/'" do
  before do
    @template = Addressable::Template.new("/")
  end

  it "should have no variables" do
    @template.variables.should be_empty
  end

  it "should have the correct mapping when extracting from '/'" do
    @template.extract("/").should == {}
  end
end

describe Addressable::URI, "when parsed from '/one/'" do
  before do
    @uri = Addressable::URI.parse("/one/")
  end

  it "should not match the pattern '/two/'" do
    Addressable::Template.new("/two/").extract(@uri).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern '/{number}/'" do
    Addressable::Template.new(
      "/{number}/"
    ).extract(@uri).should == {"number" => "one"}
  end
end

describe Addressable::Template, "created with the pattern '/{number}/'" do
  before do
    @template = Addressable::Template.new("/{number}/")
  end

  it "should have the variables ['number']" do
    @template.variables.should == ["number"]
  end

  it "should not match the pattern '/'" do
    @template.match("/").should == nil
  end

  it "should match the pattern '/two/'" do
    @template.match("/two/").mapping.should == {"number" => "two"}
  end
end

describe Addressable::Template,
    "created with the pattern '/{number}/{number}/'" do
  before do
    @template = Addressable::Template.new("/{number}/{number}/")
  end

  it "should have one variable" do
    @template.variables.should == ["number"]
  end

  it "should have the correct mapping when extracting from '/1/1/'" do
    @template.extract("/1/1/").should == {"number" => "1"}
  end

  it "should not match '/1/2/'" do
    @template.match("/1/2/").should == nil
  end

  it "should not match '/2/1/'" do
    @template.match("/2/1/").should == nil
  end

  it "should not match '/1/'" do
    @template.match("/1/").should == nil
  end

  it "should not match '/1/1/1/'" do
    @template.match("/1/1/1/").should == nil
  end

  it "should not match '/1/2/3/'" do
    @template.match("/1/2/3/").should == nil
  end
end

describe Addressable::Template,
    "created with the pattern '/{number}{-prefix|.|number}'" do
  before do
    @template = Addressable::Template.new("/{number}{-prefix|.|number}")
  end

  it "should have one variable" do
    @template.variables.should == ["number"]
  end

  it "should have the correct mapping when extracting from '/1.1'" do
    @template.extract("/1.1").should == {"number" => "1"}
  end

  it "should have the correct mapping when extracting from '/99.99'" do
    @template.extract("/99.99").should == {"number" => "99"}
  end

  it "should not match '/1.2'" do
    @template.match("/1.2").should == nil
  end

  it "should not match '/2.1'" do
    @template.match("/2.1").should == nil
  end

  it "should not match '/1'" do
    @template.match("/1").should == nil
  end

  it "should not match '/1.1.1'" do
    @template.match("/1.1.1").should == nil
  end

  it "should not match '/1.23'" do
    @template.match("/1.23").should == nil
  end
end

describe Addressable::Template,
    "created with the pattern '/{number}/{-suffix|/|number}'" do
  before do
    @template = Addressable::Template.new("/{number}/{-suffix|/|number}")
  end

  it "should have one variable" do
    @template.variables.should == ["number"]
  end

  it "should have the correct mapping when extracting from '/1/1/'" do
    @template.extract("/1/1/").should == {"number" => "1"}
  end

  it "should have the correct mapping when extracting from '/99/99/'" do
    @template.extract("/99/99/").should == {"number" => "99"}
  end

  it "should not match '/1/1'" do
    @template.match("/1/1").should == nil
  end

  it "should not match '/11/'" do
    @template.match("/11/").should == nil
  end

  it "should not match '/1/2/'" do
    @template.match("/1/2/").should == nil
  end

  it "should not match '/2/1/'" do
    @template.match("/2/1/").should == nil
  end

  it "should not match '/1/'" do
    @template.match("/1/").should == nil
  end

  it "should not match '/1/1/1/'" do
    @template.match("/1/1/1/").should == nil
  end

  it "should not match '/1/23/'" do
    @template.match("/1/23/").should == nil
  end
end

describe Addressable::Template,
    "created with the pattern '/{number}/?{-join|&|number}'" do
  before do
    @template = Addressable::Template.new(
      "/{number}/?{-join|&|number,letter}"
    )
  end

  it "should have one variable" do
    @template.variables.should == ["number", "letter"]
  end

  it "should have the correct mapping when extracting from '/1/?number=1'" do
    @template.extract("/1/?number=1").should == {"number" => "1"}
  end

  it "should have the correct mapping when extracting " +
      "from '/99/?number=99'" do
    @template.extract("/99/?number=99").should == {"number" => "99"}
  end

  it "should have the correct mapping when extracting " +
      "from '/1/?number=1&letter=a'" do
    @template.extract("/1/?number=1&letter=a").should == {
      "number" => "1", "letter" => "a"
    }
  end

  it "should not match '/1/?number=1&bogus=foo'" do
    @template.match("/1/?number=1&bogus=foo").should == nil
  end

  it "should not match '/1/?number=2'" do
    @template.match("/1/?number=2").should == nil
  end

  it "should not match '/2/?number=1'" do
    @template.match("/2/?number=1").should == nil
  end

  it "should not match '/1/?'" do
    @template.match("/1/?").should == nil
  end
end

describe Addressable::Template,
    "created with the pattern '/{number}/{-list|/|number}/'" do
  before do
    @template = Addressable::Template.new("/{number}/{-list|/|number}/")
  end

  it "should have one variable" do
    @template.variables.should == ["number"]
  end

  it "should not match '/1/1/'" do
    @template.match("/1/1/").should == nil
  end

  it "should not match '/1/2/'" do
    @template.match("/1/2/").should == nil
  end

  it "should not match '/2/1/'" do
    @template.match("/2/1/").should == nil
  end

  it "should not match '/1/1/1/'" do
    @template.match("/1/1/1/").should == nil
  end

  it "should not match '/1/1/1/1/'" do
    @template.match("/1/1/1/1/").should == nil
  end
end

describe Addressable::Template, "created with the pattern " +
    "'http://www.example.com/?{-join|&|query,number}'" do
  before do
    @template = Addressable::Template.new(
      "http://www.example.com/?{-join|&|query,number}"
    )
  end

  it "when inspected, should have the correct class name" do
    @template.inspect.should include("Addressable::Template")
  end

  it "when inspected, should have the correct object id" do
    @template.inspect.should include("%#0x" % @template.object_id)
  end

  it "should have the variables ['query', 'number']" do
    @template.variables.should == ["query", "number"]
  end

  it "should not match the pattern 'http://www.example.com/'" do
    @template.match("http://www.example.com/").should == nil
  end

  it "should match the pattern 'http://www.example.com/?'" do
    @template.match("http://www.example.com/?").mapping.should == {}
  end

  it "should match the pattern " +
      "'http://www.example.com/?query=mycelium'" do
    match = @template.match(
      "http://www.example.com/?query=mycelium"
    )
    match.variables.should == ["query", "number"]
    match.values.should == ["mycelium", nil]
    match.mapping.should == {"query" => "mycelium"}
    match.inspect.should =~ /MatchData/
  end

  it "should match the pattern " +
      "'http://www.example.com/?query=mycelium&number=100'" do
    @template.match(
      "http://www.example.com/?query=mycelium&number=100"
    ).mapping.should == {"query" => "mycelium", "number" => "100"}
  end
end

describe Addressable::URI, "when parsed from '/one/two/'" do
  before do
    @uri = Addressable::URI.parse("/one/two/")
  end

  it "should not match the pattern '/{number}/' " +
      "with the SlashlessProcessor" do
    Addressable::Template.new(
      "/{number}/"
    ).extract(@uri, SlashlessProcessor).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern '/{number}/' without a processor" do
    Addressable::Template.new("/{number}/").extract(@uri).should == {
      "number" => "one/two"
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern '/{first}/{second}/' with the SlashlessProcessor" do
    Addressable::Template.new(
      "/{first}/{second}/"
    ).extract(@uri, SlashlessProcessor).should == {
      "first" => "one",
      "second" => "two"
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/search/an+example+search+query/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/search/an+example+search+query/")
  end

  it "should have the correct mapping when extracting values using " +
      "the pattern 'http://example.com/search/{query}/' with the " +
      "ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/search/{query}/"
    ).extract(@uri, ExampleProcessor).should == {
      "query" => "an example search query"
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/search/{-list|+|query}/'" do
    Addressable::Template.new(
      "http://example.com/search/{-list|+|query}/"
    ).extract(@uri).should == {
      "query" => ["an", "example", "search", "query"]
    }
  end

  it "should return nil when extracting values using " +
      "a non-matching pattern" do
    Addressable::Template.new(
      "http://bogus.com/{thingy}/"
    ).extract(@uri).should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/a/b/c/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/a/b/c/")
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/{second}/' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{first}/{second}/"
    ).extract(@uri, ExampleProcessor).should == {
      "first" => "a",
      "second" => "b/c"
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/{-list|/|second}/'" do
    Addressable::Template.new(
      "http://example.com/{first}/{-list|/|second}/"
    ).extract(@uri).should == {
      "first" => "a",
      "second" => ["b", "c"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/{-list|/|rot13}/' " +
      "with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{first}/{-list|/|rot13}/"
    ).extract(@uri, ExampleProcessor).should == {
      "first" => "a",
      "rot13" => ["o", "p"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{-list|/|rot13}/' " +
      "with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{-list|/|rot13}/"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => ["n", "o", "p"]
    }
  end

  it "should not map to anything when extracting values " +
      "using the pattern " +
      "'http://example.com/{-list|/|rot13}/'" do
    Addressable::Template.new(
      "http://example.com/{-join|/|a,b,c}/"
    ).extract(@uri).should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?a=one&b=two&c=three'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?a=one&b=two&c=three")
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/?{-join|&|a,b,c}'" do
    Addressable::Template.new(
      "http://example.com/?{-join|&|a,b,c}"
    ).extract(@uri).should == {
      "a" => "one",
      "b" => "two",
      "c" => "three"
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?rot13=frperg'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?rot13=frperg")
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/?{-join|&|rot13}' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/?{-join|&|rot13}"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => "secret"
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.org///something///'" do
  before do
    @uri = Addressable::URI.parse("http://example.org///something///")
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern 'http://example.org{-prefix|/|parts}/'" do
    Addressable::Template.new(
      "http://example.org{-prefix|/|parts}/"
    ).extract(@uri).should == {
      "parts" => ["", "", "something", "", ""]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern 'http://example.org/{-suffix|/|parts}'" do
    Addressable::Template.new(
      "http://example.org/{-suffix|/|parts}"
    ).extract(@uri).should == {
      "parts" => ["", "", "something", "", ""]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern 'http://example.org/{-list|/|parts}'" do
    Addressable::Template.new(
      "http://example.org/{-list|/|parts}"
    ).extract(@uri).should == {
      "parts" => ["", "", "something", "", ""]
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/one/spacer/two/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/one/spacer/two/")
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/spacer/{second}/'" do
    Addressable::Template.new(
      "http://example.com/{first}/spacer/{second}/"
    ).extract(@uri).should == {
      "first" => "one",
      "second" => "two"
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com{-prefix|/|stuff}/'" do
    Addressable::Template.new(
      "http://example.com{-prefix|/|stuff}/"
    ).extract(@uri).should == {
      "stuff" => ["one", "spacer", "two"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/o{-prefix|/|stuff}/'" do
    Addressable::Template.new(
      "http://example.com/o{-prefix|/|stuff}/"
    ).extract(@uri).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/spacer{-prefix|/|stuff}/'" do
    Addressable::Template.new(
      "http://example.com/{first}/spacer{-prefix|/|stuff}/"
    ).extract(@uri).should == {
      "first" => "one",
      "stuff" => "two"
    }
  end

  it "should not match anything when extracting values " +
      "using the incorrect suffix pattern " +
      "'http://example.com/{-prefix|/|stuff}/'" do
    Addressable::Template.new(
      "http://example.com/{-prefix|/|stuff}/"
    ).extract(@uri).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com{-prefix|/|rot13}/' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com{-prefix|/|rot13}/"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => ["bar", "fcnpre", "gjb"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com{-prefix|/|rot13}' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com{-prefix|/|rot13}"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => ["bar", "fcnpre", "gjb", ""]
    }
  end

  it "should not match anything when extracting values " +
      "using the incorrect suffix pattern " +
      "'http://example.com/{-prefix|/|rot13}' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{-prefix|/|rot13}"
    ).extract(@uri, ExampleProcessor).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{-suffix|/|stuff}'" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|stuff}"
    ).extract(@uri).should == {
      "stuff" => ["one", "spacer", "two"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{-suffix|/|stuff}o'" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|stuff}o"
    ).extract(@uri).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/o{-suffix|/|stuff}'" do
    Addressable::Template.new(
      "http://example.com/o{-suffix|/|stuff}"
    ).extract(@uri).should == {"stuff"=>["ne", "spacer", "two"]}
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{first}/spacer/{-suffix|/|stuff}'" do
    Addressable::Template.new(
      "http://example.com/{first}/spacer/{-suffix|/|stuff}"
    ).extract(@uri).should == {
      "first" => "one",
      "stuff" => "two"
    }
  end

  it "should not match anything when extracting values " +
      "using the incorrect suffix pattern " +
      "'http://example.com/{-suffix|/|stuff}/'" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|stuff}/"
    ).extract(@uri).should == nil
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com/{-suffix|/|rot13}' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|rot13}"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => ["bar", "fcnpre", "gjb"]
    }
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://example.com{-suffix|/|rot13}' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com{-suffix|/|rot13}"
    ).extract(@uri, ExampleProcessor).should == {
      "rot13" => ["", "bar", "fcnpre", "gjb"]
    }
  end

  it "should not match anything when extracting values " +
      "using the incorrect suffix pattern " +
      "'http://example.com/{-suffix|/|rot13}/' with the ExampleProcessor" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|rot13}/"
    ).extract(@uri, ExampleProcessor).should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?email=bob@sporkmonger.com'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/?email=bob@sporkmonger.com"
    )
  end

  it "should not match anything when extracting values " +
      "using the incorrect opt pattern " +
      "'http://example.com/?email={-opt|bogus@bogus.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-opt|bogus@bogus.com|test}"
    ).extract(@uri).should == nil
  end

  it "should not match anything when extracting values " +
      "using the incorrect neg pattern " +
      "'http://example.com/?email={-neg|bogus@bogus.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-neg|bogus@bogus.com|test}"
    ).extract(@uri).should == nil
  end

  it "should indicate a match when extracting values " +
      "using the opt pattern " +
      "'http://example.com/?email={-opt|bob@sporkmonger.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-opt|bob@sporkmonger.com|test}"
    ).extract(@uri).should == {}
  end

  it "should indicate a match when extracting values " +
      "using the neg pattern " +
      "'http://example.com/?email={-neg|bob@sporkmonger.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-neg|bob@sporkmonger.com|test}"
    ).extract(@uri).should == {}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?email='" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/?email="
    )
  end

  it "should indicate a match when extracting values " +
      "using the opt pattern " +
      "'http://example.com/?email={-opt|bob@sporkmonger.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-opt|bob@sporkmonger.com|test}"
    ).extract(@uri).should == {}
  end

  it "should indicate a match when extracting values " +
      "using the neg pattern " +
      "'http://example.com/?email={-neg|bob@sporkmonger.com|test}'" do
    Addressable::Template.new(
      "http://example.com/?email={-neg|bob@sporkmonger.com|test}"
    ).extract(@uri).should == {}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/a/b/c/?one=1&two=2#foo'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/a/b/c/?one=1&two=2#foo"
    )
  end

  it "should have the correct mapping when extracting values " +
      "using the pattern " +
      "'http://{host}/{-suffix|/|segments}?{-join|&|one,two}\#{fragment}'" do
    Addressable::Template.new(
      "http://{host}/{-suffix|/|segments}?{-join|&|one,two}\#{fragment}"
    ).extract(@uri).should == {
      "host" => "example.com",
      "segments" => ["a", "b", "c"],
      "one" => "1",
      "two" => "2",
      "fragment" => "foo"
    }
  end

  it "should not match when extracting values " +
      "using the pattern " +
      "'http://{host}/{-suffix|/|segments}?{-join|&|one}\#{fragment}'" do
    Addressable::Template.new(
      "http://{host}/{-suffix|/|segments}?{-join|&|one}\#{fragment}"
    ).extract(@uri).should == nil
  end

  it "should not match when extracting values " +
      "using the pattern " +
      "'http://{host}/{-suffix|/|segments}?{-join|&|bogus}\#{fragment}'" do
    Addressable::Template.new(
      "http://{host}/{-suffix|/|segments}?{-join|&|bogus}\#{fragment}"
    ).extract(@uri).should == nil
  end

  it "should not match when extracting values " +
      "using the pattern " +
      "'http://{host}/{-suffix|/|segments}?" +
      "{-join|&|one,bogus}\#{fragment}'" do
    Addressable::Template.new(
      "http://{host}/{-suffix|/|segments}?{-join|&|one,bogus}\#{fragment}"
    ).extract(@uri).should == nil
  end

  it "should not match when extracting values " +
      "using the pattern " +
      "'http://{host}/{-suffix|/|segments}?" +
      "{-join|&|one,two,bogus}\#{fragment}'" do
    Addressable::Template.new(
      "http://{host}/{-suffix|/|segments}?{-join|&|one,two,bogus}\#{fragment}"
    ).extract(@uri).should == {
      "host" => "example.com",
      "segments" => ["a", "b", "c"],
      "one" => "1",
      "two" => "2",
      "fragment" => "foo"
    }
  end
end

describe Addressable::URI, "when given a pattern with bogus operators" do
  before do
    @uri = Addressable::URI.parse("http://example.com/a/b/c/")
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-bogus|/|a,b,c}/"
      ).extract(@uri)
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com{-prefix|/|a,b,c}/"
      ).extract(@uri)
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-suffix|/|a,b,c}"
      ).extract(@uri)
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-list|/|a,b,c}/"
      ).extract(@uri)
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end
end

describe Addressable::URI, "when given a mapping that contains an Array" do
  before do
    @mapping = {"query" => "an example search query".split(" ")}
  end

  it "should result in 'http://example.com/search/an+example+search+query/'" +
      " when used to expand 'http://example.com/search/{-list|+|query}/'" do
    Addressable::Template.new(
      "http://example.com/search/{-list|+|query}/"
    ).expand(@mapping).to_str.should ==
      "http://example.com/search/an+example+search+query/"
  end

  it "should result in 'http://example.com/search/an+example+search+query/'" +
      " when used to expand 'http://example.com/search/{-list|+|query}/'" +
      " with a NoOpProcessor" do
    Addressable::Template.new(
      "http://example.com/search/{-list|+|query}/"
    ).expand(@mapping, NoOpProcessor).to_str.should ==
      "http://example.com/search/an+example+search+query/"
  end
end

describe Addressable::URI, "when given an empty mapping" do
  before do
    @mapping = {}
  end

  it "should result in 'http://example.com/search/'" +
      " when used to expand 'http://example.com/search/{-list|+|query}'" do
    Addressable::Template.new(
      "http://example.com/search/{-list|+|query}"
    ).expand(@mapping).to_str.should == "http://example.com/search/"
  end

  it "should result in 'http://example.com'" +
      " when used to expand 'http://example.com{-prefix|/|foo}'" do
    Addressable::Template.new(
      "http://example.com{-prefix|/|foo}"
    ).expand(@mapping).to_str.should == "http://example.com"
  end

  it "should result in 'http://example.com'" +
      " when used to expand 'http://example.com{-suffix|/|foo}'" do
    Addressable::Template.new(
      "http://example.com{-suffix|/|foo}"
    ).expand(@mapping).to_str.should == "http://example.com"
  end
end

describe Addressable::URI, "when given the template pattern " +
    "'http://example.com/search/{query}/' " +
    "to be processed with the ExampleProcessor" do
  before do
    @pattern = "http://example.com/search/{query}/"
  end

  it "should expand to " +
      "'http://example.com/search/an+example+search+query/' " +
      "with a mapping of {\"query\" => \"an example search query\"} " do
    Addressable::Template.new(
      "http://example.com/search/{query}/"
    ).expand({
      "query" => "an example search query"
    }, ExampleProcessor).to_s.should ==
      "http://example.com/search/an+example+search+query/"
  end

  it "should raise an error " +
      "with a mapping of {\"query\" => \"invalid!\"}" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/search/{query}/"
      ).expand({"query" => "invalid!"}, ExampleProcessor).to_s
    end).should raise_error(Addressable::Template::InvalidTemplateValueError)
  end
end

# Section 3.3.1 of the URI Template draft v 01
describe Addressable::URI, "when given the mapping supplied in " +
    "Section 3.3.1 of the URI Template draft v 01" do
  before do
    @mapping = {
      "a" => "fred",
      "b" => "barney",
      "c" => "cheeseburger",
      "d" => "one two three",
      "e" => "20% tricky",
      "f" => "",
      "20" => "this-is-spinal-tap",
      "scheme" => "https",
      "p" => "quote=to+be+or+not+to+be",
      "q" => "hullo#world"
    }
  end

  it "should result in 'http://example.org/page1#fred' " +
      "when used to expand 'http://example.org/page1\#{a}'" do
    Addressable::Template.new(
      "http://example.org/page1\#{a}"
    ).expand(@mapping).to_s.should == "http://example.org/page1#fred"
  end

  it "should result in 'http://example.org/fred/barney/' " +
      "when used to expand 'http://example.org/{a}/{b}/'" do
    Addressable::Template.new(
      "http://example.org/{a}/{b}/"
    ).expand(@mapping).to_s.should == "http://example.org/fred/barney/"
  end

  it "should result in 'http://example.org/fredbarney/' " +
      "when used to expand 'http://example.org/{a}{b}/'" do
    Addressable::Template.new(
      "http://example.org/{a}{b}/"
    ).expand(@mapping).to_s.should == "http://example.org/fredbarney/"
  end

  it "should result in " +
      "'http://example.com/order/cheeseburger/cheeseburger/cheeseburger/' " +
      "when used to expand 'http://example.com/order/{c}/{c}/{c}/'" do
    Addressable::Template.new(
      "http://example.com/order/{c}/{c}/{c}/"
    ).expand(@mapping).to_s.should ==
      "http://example.com/order/cheeseburger/cheeseburger/cheeseburger/"
  end

  it "should result in 'http://example.org/one%20two%20three' " +
      "when used to expand 'http://example.org/{d}'" do
    Addressable::Template.new(
      "http://example.org/{d}"
    ).expand(@mapping).to_s.should ==
      "http://example.org/one%20two%20three"
  end

  it "should result in 'http://example.org/20%25%20tricky' " +
      "when used to expand 'http://example.org/{e}'" do
    Addressable::Template.new(
      "http://example.org/{e}"
    ).expand(@mapping).to_s.should ==
      "http://example.org/20%25%20tricky"
  end

  it "should result in 'http://example.com//' " +
      "when used to expand 'http://example.com/{f}/'" do
    Addressable::Template.new(
      "http://example.com/{f}/"
    ).expand(@mapping).to_s.should ==
      "http://example.com//"
  end

  it "should result in " +
      "'https://this-is-spinal-tap.example.org?date=&option=fred' " +
      "when used to expand " +
      "'{scheme}://{20}.example.org?date={wilma}&option={a}'" do
    Addressable::Template.new(
      "{scheme}://{20}.example.org?date={wilma}&option={a}"
    ).expand(@mapping).to_s.should ==
      "https://this-is-spinal-tap.example.org?date=&option=fred"
  end

  # The v 01 draft conflicts with the v 03 draft here.
  # The Addressable implementation uses v 03.
  it "should result in " +
      "'http://example.org?quote%3Dto%2Bbe%2Bor%2Bnot%2Bto%2Bbe' " +
      "when used to expand 'http://example.org?{p}'" do
    Addressable::Template.new(
      "http://example.org?{p}"
    ).expand(@mapping).to_s.should ==
      "http://example.org?quote%3Dto%2Bbe%2Bor%2Bnot%2Bto%2Bbe"
  end

  # The v 01 draft conflicts with the v 03 draft here.
  # The Addressable implementation uses v 03.
  it "should result in 'http://example.com/hullo%23world' " +
      "when used to expand 'http://example.com/{q}'" do
    Addressable::Template.new(
      "http://example.com/{q}"
    ).expand(@mapping).to_s.should == "http://example.com/hullo%23world"
  end
end

# Section 4.5 of the URI Template draft v 03
describe Addressable::URI, "when given the mapping supplied in " +
    "Section 4.5 of the URI Template draft v 03" do
  before do
    @mapping = {
      "foo" => "ϓ",
      "bar" => "fred",
      "baz" => "10,20,30",
      "qux" => ["10","20","30"],
      "corge" => [],
      "grault" => "",
      "garply" => "a/b/c",
      "waldo" => "ben & jerrys",
      "fred" => ["fred", "", "wilma"],
      "plugh" => ["ẛ", "ṡ"],
      "1-a_b.c" => "200"
    }
  end

  it "should result in 'http://example.org/?q=fred' " +
      "when used to expand 'http://example.org/?q={bar}'" do
    Addressable::Template.new(
      "http://example.org/?q={bar}"
    ).expand(@mapping).to_s.should == "http://example.org/?q=fred"
  end

  it "should result in '/' " +
      "when used to expand '/{xyzzy}'" do
    Addressable::Template.new(
      "/{xyzzy}"
    ).expand(@mapping).to_s.should == "/"
  end

  it "should result in " +
      "'http://example.org/?foo=%CE%8E&bar=fred&baz=10%2C20%2C30' " +
      "when used to expand " +
      "'http://example.org/?{-join|&|foo,bar,xyzzy,baz}'" do
    Addressable::Template.new(
      "http://example.org/?{-join|&|foo,bar,xyzzy,baz}"
    ).expand(@mapping).to_s.should ==
      "http://example.org/?foo=%CE%8E&bar=fred&baz=10%2C20%2C30"
  end

  it "should result in 'http://example.org/?d=10,20,30' " +
      "when used to expand 'http://example.org/?d={-list|,|qux}'" do
    Addressable::Template.new(
      "http://example.org/?d={-list|,|qux}"
    ).expand(
      @mapping
    ).to_s.should == "http://example.org/?d=10,20,30"
  end

  it "should result in 'http://example.org/?d=10&d=20&d=30' " +
      "when used to expand 'http://example.org/?d={-list|&d=|qux}'" do
    Addressable::Template.new(
      "http://example.org/?d={-list|&d=|qux}"
    ).expand(
      @mapping
    ).to_s.should == "http://example.org/?d=10&d=20&d=30"
  end

  it "should result in 'http://example.org/fredfred/a%2Fb%2Fc' " +
      "when used to expand 'http://example.org/{bar}{bar}/{garply}'" do
    Addressable::Template.new(
      "http://example.org/{bar}{bar}/{garply}"
    ).expand(
      @mapping
    ).to_s.should == "http://example.org/fredfred/a%2Fb%2Fc"
  end

  it "should result in 'http://example.org/fred/fred//wilma' " +
      "when used to expand 'http://example.org/{bar}{-prefix|/|fred}'" do
    Addressable::Template.new(
      "http://example.org/{bar}{-prefix|/|fred}"
    ).expand(
      @mapping
    ).to_s.should == "http://example.org/fred/fred//wilma"
  end

  it "should result in ':%E1%B9%A1:%E1%B9%A1:' " +
      "when used to expand '{-neg|:|corge}{-suffix|:|plugh}'" do
    Addressable::Template.new(
      "{-neg|:|corge}{-suffix|:|plugh}"
    ).expand(
      @mapping
    ).to_s.should == ":%E1%B9%A1:%E1%B9%A1:"
  end

  it "should result in '../ben%20%26%20jerrys/' " +
      "when used to expand '../{waldo}/'" do
    Addressable::Template.new(
      "../{waldo}/"
    ).expand(
      @mapping
    ).to_s.should == "../ben%20%26%20jerrys/"
  end

  it "should result in 'telnet:192.0.2.16:80' " +
      "when used to expand 'telnet:192.0.2.16{-opt|:80|grault}'" do
    Addressable::Template.new(
      "telnet:192.0.2.16{-opt|:80|grault}"
    ).expand(
      @mapping
    ).to_s.should == "telnet:192.0.2.16:80"
  end

  it "should result in ':200:' " +
      "when used to expand ':{1-a_b.c}:'" do
    Addressable::Template.new(
      ":{1-a_b.c}:"
    ).expand(
      @mapping
    ).to_s.should == ":200:"
  end
end

describe Addressable::URI, "when given a mapping that contains a " +
  "template-var within a value" do
  before do
    @mapping = {
      "a" => "{b}",
      "b" => "barney",
    }
  end

  it "should result in 'http://example.com/%7Bb%7D/barney/' " +
      "when used to expand 'http://example.com/{a}/{b}/'" do
    Addressable::Template.new(
      "http://example.com/{a}/{b}/"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com/%7Bb%7D/barney/"
  end

  it "should result in 'http://example.com//%7Bb%7D/' " +
      "when used to expand 'http://example.com/{-opt|foo|foo}/{a}/'" do
    Addressable::Template.new(
      "http://example.com/{-opt|foo|foo}/{a}/"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com//%7Bb%7D/"
  end

  it "should result in 'http://example.com//%7Bb%7D/' " +
      "when used to expand 'http://example.com/{-neg|foo|b}/{a}/'" do
    Addressable::Template.new(
      "http://example.com/{-neg|foo|b}/{a}/"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com//%7Bb%7D/"
  end

  it "should result in 'http://example.com//barney/%7Bb%7D/' " +
      "when used to expand 'http://example.com/{-prefix|/|b}/{a}/'" do
    Addressable::Template.new(
      "http://example.com/{-prefix|/|b}/{a}/"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com//barney/%7Bb%7D/"
  end

  it "should result in 'http://example.com/barney//%7Bb%7D/' " +
      "when used to expand 'http://example.com/{-suffix|/|b}/{a}/'" do
    Addressable::Template.new(
      "http://example.com/{-suffix|/|b}/{a}/"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com/barney//%7Bb%7D/"
  end

  it "should result in 'http://example.com/%7Bb%7D/?b=barney&c=42' " +
      "when used to expand 'http://example.com/{a}/?{-join|&|b,c=42}'" do
    Addressable::Template.new(
      "http://example.com/{a}/?{-join|&|b,c=42}"
    ).expand(
      @mapping
    ).to_s.should == "http://example.com/%7Bb%7D/?b=barney&c=42"
  end

  it "should result in 'http://example.com/42/?b=barney' " +
      "when used to expand 'http://example.com/{c=42}/?{-join|&|b}'" do
    Addressable::Template.new(
      "http://example.com/{c=42}/?{-join|&|b}"
    ).expand(@mapping).to_s.should == "http://example.com/42/?b=barney"
  end
end

describe Addressable::URI, "when given a single variable mapping" do
  before do
    @mapping = {
      "foo" => "fred"
    }
  end

  it "should result in 'fred' when used to expand '{foo}'" do
    Addressable::Template.new(
      "{foo}"
    ).expand(@mapping).to_s.should == "fred"
  end

  it "should result in 'wilma' when used to expand '{bar=wilma}'" do
    Addressable::Template.new(
      "{bar=wilma}"
    ).expand(@mapping).to_s.should == "wilma"
  end

  it "should result in '' when used to expand '{baz}'" do
    Addressable::Template.new(
      "{baz}"
    ).expand(@mapping).to_s.should == ""
  end
end

describe Addressable::URI, "when given a simple mapping" do
  before do
    @mapping = {
      "foo" => "fred",
      "bar" => "barney",
      "baz" => ""
    }
  end

  it "should result in 'foo=fred&bar=barney&baz=' when used to expand " +
      "'{-join|&|foo,bar,baz,qux}'" do
    Addressable::Template.new(
      "{-join|&|foo,bar,baz,qux}"
    ).expand(@mapping).to_s.should == "foo=fred&bar=barney&baz="
  end

  it "should result in 'bar=barney' when used to expand " +
      "'{-join|&|bar}'" do
    Addressable::Template.new(
      "{-join|&|bar}"
    ).expand(@mapping).to_s.should == "bar=barney"
  end

  it "should result in '' when used to expand " +
      "'{-join|&|qux}'" do
    Addressable::Template.new(
      "{-join|&|qux}"
    ).expand(@mapping).to_s.should == ""
  end
end

describe Addressable::URI, "extracting defaults from a pattern" do
  before do
    @template = Addressable::Template.new("{foo}{bar=baz}{-opt|found|cond}")
  end

  it "should extract default value" do
    @template.variable_defaults.should == {"bar" => "baz"}
  end
end

describe Addressable::URI, "when given a mapping with symbol keys" do
  before do
    @mapping = { :name => "fred" }
  end

  it "should result in 'fred' when used to expand '{foo}'" do
    Addressable::Template.new(
      "{name}"
    ).expand(@mapping).to_s.should == "fred"
  end
end

describe Addressable::URI, "when given a mapping with bogus keys" do
  before do
    @mapping = { Object.new => "fred" }
  end

  it "should raise an error" do
    (lambda do
      Addressable::Template.new(
        "{name}"
      ).expand(@mapping)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when given a mapping with numeric values" do
  before do
    @mapping = { :id => 123 }
  end

  it "should result in 'fred' when used to expand '{foo}'" do
    Addressable::Template.new(
      "{id}"
    ).expand(@mapping).to_s.should == "123"
  end
end

describe Addressable::URI, "when given a mapping containing values " +
    "that are already percent-encoded" do
  before do
    @mapping = {
      "a" => "%7Bb%7D"
    }
  end

  it "should result in 'http://example.com/%257Bb%257D/' " +
      "when used to expand 'http://example.com/{a}/'" do
    Addressable::Template.new(
      "http://example.com/{a}/"
    ).expand(@mapping).to_s.should == "http://example.com/%257Bb%257D/"
  end
end

describe Addressable::URI, "when given a pattern with bogus operators" do
  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-bogus|/|a,b,c}/"
      ).expand({
        "a" => "a", "b" => "b", "c" => "c"
      })
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-prefix|/|a,b,c}/"
      ).expand({
        "a" => "a", "b" => "b", "c" => "c"
      })
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-suffix|/|a,b,c}/"
      ).expand({
        "a" => "a", "b" => "b", "c" => "c"
      })
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-join|/|a,b,c}/"
      ).expand({
        "a" => ["a"], "b" => ["b"], "c" => "c"
      })
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end

  it "should raise an InvalidTemplateOperatorError" do
    (lambda do
      Addressable::Template.new(
        "http://example.com/{-list|/|a,b,c}/"
      ).expand({
        "a" => ["a"], "b" => ["b"], "c" => "c"
      })
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{one}/{two}/"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1", "two" => "2"}).should ==
      @partial_template.expand({"two" => "2"})
  end

  it "should raise an error if the template is expanded with bogus values" do
    (lambda do
      @initial_template.expand({"one" => Object.new, "two" => Object.new})
    end).should raise_error(TypeError)
    (lambda do
      @partial_template.expand({"two" => Object.new})
    end).should raise_error(TypeError)
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{one}/{two}/"
    )
    @partial_template = @initial_template.partial_expand({"two" => "2"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1", "two" => "2"}).should ==
      @partial_template.expand({"one" => "1"})
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{one}/{two}/"
    )
    @partial_template = @initial_template.partial_expand({"two" => "2"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1", "two" => "2"}).should ==
      @partial_template.expand({"one" => "1"})
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{one=1}/{two=2}/"
    )
    @partial_template = @initial_template.partial_expand({"one" => "3"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "3", "two" => "4"}).should ==
      @partial_template.expand({"two" => "4"})
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).should === "http://example.com/3/2/"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{one=1}/{two=2}/"
    )
    @partial_template = @initial_template.partial_expand({"two" => "4"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "3", "two" => "4"}).should ==
      @partial_template.expand({"one" => "3"})
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).should === "http://example.com/1/4/"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-opt|found|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/found"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/found"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"three" => "3"}).to_str.should ==
      "http://example.com/found"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"four" => "4"}).to_str.should ==
      "http://example.com/"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      "http://example.com/found"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-opt|found|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/found"
  end

  it "should produce the correct pattern" do
    @partial_template.pattern.should == "http://example.com/found"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-neg|notfound|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/notfound"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"three" => "3"}).to_str.should ==
      "http://example.com/"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"four" => "4"}).to_str.should ==
      "http://example.com/notfound"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      "http://example.com/"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-neg|notfound|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/"
  end

  it "should produce the correct pattern" do
    @partial_template.pattern.should == "http://example.com/"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-prefix|x=|one}"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"one" => "1"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/?x=1"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/?"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      "http://example.com/?x=1"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-prefix|x=|one}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?x=1"
  end

  it "should produce the correct pattern" do
    @partial_template.pattern.should == "http://example.com/?x=1"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-suffix|=x|one}"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"one" => "1"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/?1=x"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/?"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      "http://example.com/?1=x"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-suffix|=x|one}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?1=x"
  end

  it "should produce the correct pattern" do
    @partial_template.pattern.should == "http://example.com/?1=x"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one}"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1"}).to_str.should ==
      @partial_template.expand({"one" => "1"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.pattern.should == @initial_template.pattern
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?one=1"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two}"
    )
    @partial_template = @initial_template.partial_expand({"two" => "2"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({"one" => "1", "two" => "2"}).to_str.should ==
      @partial_template.expand({"one" => "1"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?two=2"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({"one" => "1"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"two" => "2", "three" => "3"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?one=1"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/?one=1&two=2"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"three" => "3"}).to_str.should ==
      "http://example.com/?one=1&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({"two" => "2"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"one" => "1", "three" => "3"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?two=2"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/?one=1&two=2"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"three" => "3"}).to_str.should ==
      "http://example.com/?two=2&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({"three" => "3"})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"one" => "1", "two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/?three=3"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/?one=1&three=3"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/?two=2&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({
      "one" => "1", "two" => "2"
    })
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"three" => "3"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should ==
      "http://example.com/?one=1&two=2"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"three" => "3"}).to_str.should ==
      "http://example.com/?one=1&two=2&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({
      "one" => "1", "three" => "3"
    })
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"two" => "2"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should ==
      "http://example.com/?one=1&three=3"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"two" => "2"}).to_str.should ==
      "http://example.com/?one=1&two=2&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
    @partial_template = @initial_template.partial_expand({
      "two" => "2", "three" => "3"
    })
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "one" => "1", "two" => "2", "three" => "3"
    }).to_str.should ==
      @partial_template.expand({"one" => "1"}).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should ==
      "http://example.com/?two=2&three=3"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({"one" => "1"}).to_str.should ==
      "http://example.com/?one=1&two=2&three=3"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/?{-join|&|one,two,three}"
    )
  end

  it "should raise an error when partially expanding a bogus operator" do
    (lambda do
      @initial_template.partial_expand({"one" => ["1"]})
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
    (lambda do
      @initial_template.partial_expand({"two" => "2", "three" => ["3"]})
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-list|/|numbers}/{-list|/|letters}/"
    )
    @partial_template = @initial_template.partial_expand({})
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "numbers" => ["1", "2", "3"], "letters" => ["a", "b", "c"]
    }).to_str.should == @partial_template.expand({
      "numbers" => ["1", "2", "3"], "letters" => ["a", "b", "c"]
    }).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com///"
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.pattern.should == @initial_template.pattern
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-list|/|numbers}/{-list|/|letters}/"
    )
    @partial_template = @initial_template.partial_expand({
      "numbers" => ["1", "2", "3"]
    })
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "numbers" => ["1", "2", "3"], "letters" => ["a", "b", "c"]
    }).to_str.should == @partial_template.expand({
      "letters" => ["a", "b", "c"]
    }).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com/1/2/3//"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-list|/|numbers}/{-list|/|letters}/"
    )
    @partial_template = @initial_template.partial_expand({
      "letters" => ["a", "b", "c"]
    })
  end

  it "should produce the same result when fully expanded" do
    @initial_template.expand({
      "numbers" => ["1", "2", "3"], "letters" => ["a", "b", "c"]
    }).to_str.should == @partial_template.expand({
      "numbers" => ["1", "2", "3"]
    }).to_str
  end

  it "should produce the correct result when fully expanded" do
    @partial_template.expand({}).to_str.should == "http://example.com//a/b/c/"
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-list|/|numbers}/{-list|/|letters}/"
    )
  end

  it "should raise an error when partially expanding a bogus operator" do
    (lambda do
      @initial_template.partial_expand({"numbers" => "1"})
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
    (lambda do
      @initial_template.partial_expand({"letters" => "a"})
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end
end

describe Addressable::Template, "with a partially expanded template" do
  before do
    @initial_template = Addressable::Template.new(
      "http://example.com/{-bogus|/|one,two}/"
    )
  end

  it "should raise an error when partially expanding a bogus operator" do
    (lambda do
      @initial_template.partial_expand({"one" => "1"})
    end).should raise_error(
      Addressable::Template::InvalidTemplateOperatorError
    )
  end
end
