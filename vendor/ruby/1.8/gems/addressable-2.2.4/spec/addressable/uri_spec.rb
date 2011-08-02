# encoding: utf-8
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

require "addressable/uri"

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

module URI
  class HTTP
    def initialize(uri)
      @uri = uri
    end

    def to_s
      return @uri.to_s
    end
  end
end

describe Addressable::URI, "when created with a non-numeric port number" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:port => "bogus")
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created with a non-string scheme" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:scheme => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string user" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:user => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string password" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:password => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string userinfo" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:userinfo => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string host" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:host => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string authority" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:authority => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string authority" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:authority => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string path" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:path => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string query" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:query => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a non-string fragment" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:fragment => :bogus)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when created with a scheme but no hierarchical " +
    "segment" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.parse("http:")
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created from nil components" do
  before do
    @uri = Addressable::URI.new
  end

  it "should have a nil site value" do
    @uri.site.should == nil
  end

  it "should have an empty path" do
    @uri.path.should == ""
  end

  it "should be an empty uri" do
    @uri.to_s.should == ""
  end

  it "should raise an error if the scheme is set to whitespace" do
    (lambda do
      @uri.scheme = "\t \n"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should raise an error if the scheme is set to all digits" do
    (lambda do
      @uri.scheme = "123"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should raise an error if set into an invalid state" do
    (lambda do
      @uri.user = "user"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should raise an error if set into an invalid state" do
    (lambda do
      @uri.password = "pass"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should raise an error if set into an invalid state" do
    (lambda do
      @uri.scheme = "http"
      @uri.fragment = "fragment"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should raise an error if set into an invalid state" do
    (lambda do
      @uri.fragment = "fragment"
      @uri.scheme = "http"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created from string components" do
  before do
    @uri = Addressable::URI.new(
      :scheme => "http", :host => "example.com"
    )
  end

  it "should have a site value of 'http://example.com'" do
    @uri.site.should == "http://example.com"
  end

  it "should be equal to the equivalent parsed URI" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  it "should raise an error if invalid components omitted" do
    (lambda do
      @uri.omit(:bogus)
    end).should raise_error(ArgumentError)
    (lambda do
      @uri.omit(:scheme, :bogus, :path)
    end).should raise_error(ArgumentError)
  end
end

describe Addressable::URI, "when created with a nil host but " +
    "non-nil authority components" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:user => "user", :password => "pass", :port => 80)
    end).should raise_error(Addressable::URI::InvalidURIError)
  end
end

describe Addressable::URI, "when created with both an authority and a user" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(
        :user => "user", :authority => "user@example.com:80"
      )
    end).should raise_error(ArgumentError)
  end
end

describe Addressable::URI, "when created with an authority and no port" do
  before do
    @uri = Addressable::URI.new(:authority => "user@example.com")
  end

  it "should not infer a port" do
    @uri.port.should == nil
    @uri.inferred_port.should == nil
  end

  it "should have a site value of '//user@example.com'" do
    @uri.site.should == "//user@example.com"
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when created with both a userinfo and a user" do
  it "should raise an error" do
    (lambda do
      Addressable::URI.new(:user => "user", :userinfo => "user:pass")
    end).should raise_error(ArgumentError)
  end
end

describe Addressable::URI, "when created with a path that hasn't been " +
    "prefixed with a '/' but a host specified" do
  before do
    @uri = Addressable::URI.new(
      :scheme => "http", :host => "example.com", :path => "path"
    )
  end

  it "should prefix a '/' to the path" do
    @uri.should == Addressable::URI.parse("http://example.com/path")
  end

  it "should have a site value of 'http://example.com'" do
    @uri.site.should == "http://example.com"
  end

  it "should have an origin of 'http://example.com" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when created with a path that hasn't been " +
    "prefixed with a '/' but no host specified" do
  before do
    @uri = Addressable::URI.new(
      :scheme => "http", :path => "path"
    )
  end

  it "should not prefix a '/' to the path" do
    @uri.should == Addressable::URI.parse("http:path")
  end

  it "should have a site value of 'http:'" do
    @uri.site.should == "http:"
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from an Addressable::URI object" do
  it "should return the object" do
    uri = Addressable::URI.parse("http://example.com/")
    (lambda do
      Addressable::URI.parse(uri).object_id.should == uri.object_id
    end).should_not raise_error
  end

  it "should return the object" do
    uri = Addressable::URI.parse("http://example.com/")
    (lambda do
      Addressable::URI.heuristic_parse(uri).object_id.should == uri.object_id
    end).should_not raise_error
  end
end

describe Addressable::URI, "when parsed from something that looks " +
    "like a URI object" do
  it "should parse without error" do
    uri = Addressable::URI.parse(URI::HTTP.new("http://example.com/"))
    (lambda do
      Addressable::URI.parse(uri)
    end).should_not raise_error
  end
end

describe Addressable::URI, "when parsed from ''" do
  before do
    @uri = Addressable::URI.parse("")
  end

  it "should have no scheme" do
    @uri.scheme.should == nil
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of ''" do
    @uri.path.should == ""
  end

  it "should have a request URI of '/'" do
    @uri.request_uri.should == "/"
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'ftp://ftp.is.co.za/rfc/rfc1808.txt'" do
  before do
    @uri = Addressable::URI.parse("ftp://ftp.is.co.za/rfc/rfc1808.txt")
  end

  it "should use the 'ftp' scheme" do
    @uri.scheme.should == "ftp"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of 'ftp.is.co.za'" do
    @uri.host.should == "ftp.is.co.za"
  end

  it "should have a path of '/rfc/rfc1808.txt'" do
    @uri.path.should == "/rfc/rfc1808.txt"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have an origin of 'ftp://ftp.is.co.za'" do
    @uri.origin.should == 'ftp://ftp.is.co.za'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'http://www.ietf.org/rfc/rfc2396.txt'" do
  before do
    @uri = Addressable::URI.parse("http://www.ietf.org/rfc/rfc2396.txt")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of 'www.ietf.org'" do
    @uri.host.should == "www.ietf.org"
  end

  it "should have a path of '/rfc/rfc2396.txt'" do
    @uri.path.should == "/rfc/rfc2396.txt"
  end

  it "should have a request URI of '/rfc/rfc2396.txt'" do
    @uri.request_uri.should == "/rfc/rfc2396.txt"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should correctly omit components" do
    @uri.omit(:scheme).to_s.should == "//www.ietf.org/rfc/rfc2396.txt"
    @uri.omit(:path).to_s.should == "http://www.ietf.org"
  end

  it "should correctly omit components destructively" do
    @uri.omit!(:scheme)
    @uri.to_s.should == "//www.ietf.org/rfc/rfc2396.txt"
  end

  it "should have an origin of 'http://www.ietf.org'" do
    @uri.origin.should == 'http://www.ietf.org'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'ldap://[2001:db8::7]/c=GB?objectClass?one'" do
  before do
    @uri = Addressable::URI.parse("ldap://[2001:db8::7]/c=GB?objectClass?one")
  end

  it "should use the 'ldap' scheme" do
    @uri.scheme.should == "ldap"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a host of '[2001:db8::7]'" do
    @uri.host.should == "[2001:db8::7]"
  end

  it "should have a path of '/c=GB'" do
    @uri.path.should == "/c=GB"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should not allow request URI assignment" do
    (lambda do
      @uri.request_uri = "/"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should have a query of 'objectClass?one'" do
    @uri.query.should == "objectClass?one"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should correctly omit components" do
    @uri.omit(:scheme, :authority).to_s.should == "/c=GB?objectClass?one"
    @uri.omit(:path).to_s.should == "ldap://[2001:db8::7]?objectClass?one"
  end

  it "should correctly omit components destructively" do
    @uri.omit!(:scheme, :authority)
    @uri.to_s.should == "/c=GB?objectClass?one"
  end

  it "should raise an error if omission would create an invalid URI" do
    (lambda do
      @uri.omit(:authority, :path)
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should have an origin of 'ldap://[2001:db8::7]'" do
    @uri.origin.should == 'ldap://[2001:db8::7]'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'mailto:John.Doe@example.com'" do
  before do
    @uri = Addressable::URI.parse("mailto:John.Doe@example.com")
  end

  it "should use the 'mailto' scheme" do
    @uri.scheme.should == "mailto"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'John.Doe@example.com'" do
    @uri.path.should == "John.Doe@example.com"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'news:comp.infosystems.www.servers.unix'" do
  before do
    @uri = Addressable::URI.parse("news:comp.infosystems.www.servers.unix")
  end

  it "should use the 'news' scheme" do
    @uri.scheme.should == "news"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'comp.infosystems.www.servers.unix'" do
    @uri.path.should == "comp.infosystems.www.servers.unix"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'tel:+1-816-555-1212'" do
  before do
    @uri = Addressable::URI.parse("tel:+1-816-555-1212")
  end

  it "should use the 'tel' scheme" do
    @uri.scheme.should == "tel"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of '+1-816-555-1212'" do
    @uri.path.should == "+1-816-555-1212"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'telnet://192.0.2.16:80/'" do
  before do
    @uri = Addressable::URI.parse("telnet://192.0.2.16:80/")
  end

  it "should use the 'telnet' scheme" do
    @uri.scheme.should == "telnet"
  end

  it "should have a host of '192.0.2.16'" do
    @uri.host.should == "192.0.2.16"
  end

  it "should have a port of '80'" do
    @uri.port.should == 80
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have an origin of 'telnet://192.0.2.16:80'" do
    @uri.origin.should == 'telnet://192.0.2.16:80'
  end
end

# Section 1.1.2 of RFC 3986
describe Addressable::URI, "when parsed from " +
    "'urn:oasis:names:specification:docbook:dtd:xml:4.1.2'" do
  before do
    @uri = Addressable::URI.parse(
      "urn:oasis:names:specification:docbook:dtd:xml:4.1.2")
  end

  it "should use the 'urn' scheme" do
    @uri.scheme.should == "urn"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of " +
      "'oasis:names:specification:docbook:dtd:xml:4.1.2'" do
    @uri.path.should == "oasis:names:specification:docbook:dtd:xml:4.1.2"
  end

  it "should not have a request URI" do
    @uri.request_uri.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com'" do
  before do
    @uri = Addressable::URI.parse("http://example.com")
  end

  it "when inspected, should have the correct URI" do
    @uri.inspect.should include("http://example.com")
  end

  it "when inspected, should have the correct class name" do
    @uri.inspect.should include("Addressable::URI")
  end

  it "when inspected, should have the correct object id" do
    @uri.inspect.should include("%#0x" % @uri.object_id)
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should be considered ip-based" do
    @uri.should be_ip_based
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should not have a specified port" do
    @uri.port.should == nil
  end

  it "should have an empty path" do
    @uri.path.should == ""
  end

  it "should have no query string" do
    @uri.query.should == nil
    @uri.query_values.should == nil
  end

  it "should have a request URI of '/'" do
    @uri.request_uri.should == "/"
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should not be exactly equal to 42" do
    @uri.eql?(42).should == false
  end

  it "should not be equal to 42" do
    (@uri == 42).should == false
  end

  it "should not be roughly equal to 42" do
    (@uri === 42).should == false
  end

  it "should be exactly equal to http://example.com" do
    @uri.eql?(Addressable::URI.parse("http://example.com")).should == true
  end

  it "should be roughly equal to http://example.com/" do
    (@uri === Addressable::URI.parse("http://example.com/")).should == true
  end

  it "should be roughly equal to the string 'http://example.com/'" do
    (@uri === "http://example.com/").should == true
  end

  it "should not be roughly equal to the string " +
      "'http://example.com:bogus/'" do
    (lambda do
      (@uri === "http://example.com:bogus/").should == false
    end).should_not raise_error
  end

  it "should result in itself when joined with itself" do
    @uri.join(@uri).to_s.should == "http://example.com"
    @uri.join!(@uri).to_s.should == "http://example.com"
  end

  it "should be equivalent to http://EXAMPLE.com" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.com")
  end

  it "should be equivalent to http://EXAMPLE.com:80/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.com:80/")
  end

  it "should have the same hash as http://example.com" do
    @uri.hash.should == Addressable::URI.parse("http://example.com").hash
  end

  it "should have the same hash as http://EXAMPLE.com after assignment" do
    @uri.host = "EXAMPLE.com"
    @uri.hash.should == Addressable::URI.parse("http://EXAMPLE.com").hash
  end

  it "should have a different hash from http://EXAMPLE.com" do
    @uri.hash.should_not == Addressable::URI.parse("http://EXAMPLE.com").hash
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com/" do
    @uri.should == Addressable::URI.parse("http://example.com/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equivalent to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Section 6.2.2.1 of RFC 3986
  it "should be equivalent to http://EXAMPLE.COM/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.COM/")
  end

  it "should have a route of '/path/' to 'http://example.com/path/'" do
    @uri.route_to("http://example.com/path/").should ==
      Addressable::URI.parse("/path/")
  end

  it "should have a route of '/' from 'http://example.com/path/'" do
    @uri.route_from("http://example.com/path/").should ==
      Addressable::URI.parse("/")
  end

  it "should have a route of '#' to 'http://example.com/'" do
    @uri.route_to("http://example.com/").should ==
      Addressable::URI.parse("#")
  end

  it "should have a route of 'http://elsewhere.com/' to " +
      "'http://elsewhere.com/'" do
    @uri.route_to("http://elsewhere.com/").should ==
      Addressable::URI.parse("http://elsewhere.com/")
  end

  it "when joined with 'relative/path' should be " +
      "'http://example.com/relative/path'" do
    @uri.join('relative/path').should ==
      Addressable::URI.parse("http://example.com/relative/path")
  end

  it "when joined with a bogus object a TypeError should be raised" do
    (lambda do
      @uri.join(42)
    end).should raise_error(TypeError)
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
  end

  it "should have the correct username after assignment" do
    @uri.user = "user@123!"
    @uri.user.should == "user@123!"
    @uri.normalized_user.should == "user%40123%21"
    @uri.password.should == nil
    @uri.normalize.to_s.should == "http://user%40123%21@example.com/"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "secret@123!"
    @uri.password.should == "secret@123!"
    @uri.normalized_password.should == "secret%40123%21"
    @uri.user.should == ""
    @uri.normalize.to_s.should == "http://:secret%40123%21@example.com/"
    @uri.omit(:password).to_s.should == "http://example.com"
  end

  it "should have the correct user/pass after repeated assignment" do
    @uri.user = nil
    @uri.user.should == nil
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    # Username cannot be nil if the password is set
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = nil
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = ""
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user = nil
    # Username cannot be nil if the password is set
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct user/pass after userinfo assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.userinfo = nil
    @uri.userinfo.should == nil
    @uri.user.should == nil
    @uri.password.should == nil
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

# Section 5.1.2 of RFC 2616
describe Addressable::URI, "when parsed from " +
    "'http://www.w3.org/pub/WWW/TheProject.html'" do
  before do
    @uri = Addressable::URI.parse("http://www.w3.org/pub/WWW/TheProject.html")
  end

  it "should have the correct request URI" do
    @uri.request_uri.should == "/pub/WWW/TheProject.html"
  end

  it "should have the correct request URI after assignment" do
    @uri.request_uri = "/some/where/else.html?query?string"
    @uri.request_uri.should == "/some/where/else.html?query?string"
    @uri.path.should == "/some/where/else.html"
    @uri.query.should == "query?string"
  end

  it "should have the correct request URI after assignment" do
    @uri.request_uri = "?x=y"
    @uri.request_uri.should == "/?x=y"
    @uri.path.should == "/"
    @uri.query.should == "x=y"
  end

  it "should raise an error if the site value is set to something bogus" do
    (lambda do
      @uri.site = 42
    end).should raise_error(TypeError)
  end

  it "should raise an error if the request URI is set to something bogus" do
    (lambda do
      @uri.request_uri = 42
    end).should raise_error(TypeError)
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "www.w3.org",
      :port => nil,
      :path => "/pub/WWW/TheProject.html",
      :query => nil,
      :fragment => nil
    }
  end

  it "should have an origin of 'http://www.w3.org'" do
    @uri.origin.should == 'http://www.w3.org'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to HTTP://example.com/" do
    @uri.should == Addressable::URI.parse("HTTP://example.com/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://Example.com/" do
    @uri.should == Addressable::URI.parse("http://Example.com/")
  end

  it "should have the correct username after assignment" do
    @uri.user = nil
    @uri.user.should == nil
    @uri.password.should == nil
    @uri.to_s.should == "http://example.com/"
  end

  it "should have the correct password after assignment" do
    @uri.password = nil
    @uri.password.should == nil
    @uri.user.should == nil
    @uri.to_s.should == "http://example.com/"
  end

  it "should have a request URI of '/'" do
    @uri.request_uri.should == "/"
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have the same hash as its duplicate" do
    @uri.hash.should == @uri.dup.hash
  end

  it "should have a different hash from its equivalent String value" do
    @uri.hash.should_not == @uri.to_s.hash
  end

  it "should have the same hash as an equal URI" do
    @uri.hash.should == Addressable::URI.parse("http://example.com/").hash
  end

  it "should be equivalent to http://EXAMPLE.com" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.com")
  end

  it "should be equivalent to http://EXAMPLE.com:80/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.com:80/")
  end

  it "should have the same hash as http://example.com/" do
    @uri.hash.should == Addressable::URI.parse("http://example.com/").hash
  end

  it "should have the same hash as http://example.com after assignment" do
    @uri.path = ""
    @uri.hash.should == Addressable::URI.parse("http://example.com").hash
  end

  it "should have the same hash as http://example.com/? after assignment" do
    @uri.query = ""
    @uri.hash.should == Addressable::URI.parse("http://example.com/?").hash
  end

  it "should have the same hash as http://example.com/? after assignment" do
    @uri.query_values = {}
    @uri.hash.should == Addressable::URI.parse("http://example.com/?").hash
  end

  it "should have the same hash as http://example.com/# after assignment" do
    @uri.fragment = ""
    @uri.hash.should == Addressable::URI.parse("http://example.com/#").hash
  end

  it "should have a different hash from http://example.com" do
    @uri.hash.should_not == Addressable::URI.parse("http://example.com").hash
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://@example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://@example.com/")
  end

  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => "",
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com./'" do
  before do
    @uri = Addressable::URI.parse("http://example.com./")
  end

  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://:@example.com/'" do
  before do
    @uri = Addressable::URI.parse("http://:@example.com/")
  end

  it "should be equivalent to http://example.com" do
    @uri.should == Addressable::URI.parse("http://example.com")
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => "",
      :password => "",
      :host => "example.com",
      :port => nil,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/~smith/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/~smith/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com/%7Esmith/" do
    @uri.should == Addressable::URI.parse("http://example.com/%7Esmith/")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to http://example.com/%7esmith/" do
    @uri.should == Addressable::URI.parse("http://example.com/%7esmith/")
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/%E8'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/%E8")
  end

  it "should not raise an exception when normalized" do
    (lambda do
      @uri.normalize
    end).should_not raise_error(ArgumentError)
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should not change if encoded with the normalizing algorithm" do
    Addressable::URI.normalized_encode(@uri).to_s.should ==
      "http://example.com/%E8"
    Addressable::URI.normalized_encode(@uri, Addressable::URI).to_s.should ===
      "http://example.com/%E8"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/path%2Fsegment/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/path%2Fsegment/")
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should be equal to 'http://example.com/path%2Fsegment/'" do
    @uri.normalize.should be_eql(
      Addressable::URI.parse("http://example.com/path%2Fsegment/")
    )
  end

  it "should not be equal to 'http://example.com/path/segment/'" do
    @uri.should_not ==
      Addressable::URI.parse("http://example.com/path/segment/")
  end

  it "should not be equal to 'http://example.com/path/segment/'" do
    @uri.normalize.should_not be_eql(
      Addressable::URI.parse("http://example.com/path/segment/")
    )
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?%F6'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?%F6")
  end

  it "should not raise an exception when normalized" do
    (lambda do
      @uri.normalize
    end).should_not raise_error(ArgumentError)
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should not change if encoded with the normalizing algorithm" do
    Addressable::URI.normalized_encode(@uri).to_s.should ==
      "http://example.com/?%F6"
    Addressable::URI.normalized_encode(@uri, Addressable::URI).to_s.should ===
      "http://example.com/?%F6"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/#%F6'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/#%F6")
  end

  it "should not raise an exception when normalized" do
    (lambda do
      @uri.normalize
    end).should_not raise_error(ArgumentError)
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should not change if encoded with the normalizing algorithm" do
    Addressable::URI.normalized_encode(@uri).to_s.should ==
      "http://example.com/#%F6"
    Addressable::URI.normalized_encode(@uri, Addressable::URI).to_s.should ===
      "http://example.com/#%F6"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/%C3%87'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/%C3%87")
  end

  # Based on http://intertwingly.net/blog/2004/07/31/URI-Equivalence
  it "should be equivalent to 'http://example.com/C%CC%A7'" do
    @uri.should == Addressable::URI.parse("http://example.com/C%CC%A7")
  end

  it "should not change if encoded with the normalizing algorithm" do
    Addressable::URI.normalized_encode(@uri).to_s.should ==
      "http://example.com/%C3%87"
    Addressable::URI.normalized_encode(@uri, Addressable::URI).to_s.should ===
      "http://example.com/%C3%87"
  end

  it "should raise an error if encoding with an unexpected return type" do
    (lambda do
      Addressable::URI.normalized_encode(@uri, Integer)
    end).should raise_error(TypeError)
  end

  it "if percent encoded should be 'http://example.com/C%25CC%25A7'" do
    Addressable::URI.encode(@uri).to_s.should ==
      "http://example.com/%25C3%2587"
  end

  it "if percent encoded should be 'http://example.com/C%25CC%25A7'" do
    Addressable::URI.encode(@uri, Addressable::URI).should ==
      Addressable::URI.parse("http://example.com/%25C3%2587")
  end

  it "should raise an error if encoding with an unexpected return type" do
    (lambda do
      Addressable::URI.encode(@uri, Integer)
    end).should raise_error(TypeError)
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?q=string'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q=string")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should have a query string of 'q=string'" do
    @uri.query.should == "q=string"
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com:80/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com:80/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com:80'" do
    @uri.authority.should == "example.com:80"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.port.should == 80
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should be exactly equal to http://example.com:80/" do
    @uri.eql?(Addressable::URI.parse("http://example.com:80/")).should == true
  end

  it "should be roughly equal to http://example.com/" do
    (@uri === Addressable::URI.parse("http://example.com/")).should == true
  end

  it "should be roughly equal to the string 'http://example.com/'" do
    (@uri === "http://example.com/").should == true
  end

  it "should not be roughly equal to the string " +
      "'http://example.com:bogus/'" do
    (lambda do
      (@uri === "http://example.com:bogus/").should == false
    end).should_not raise_error
  end

  it "should result in itself when joined with itself" do
    @uri.join(@uri).to_s.should == "http://example.com:80/"
    @uri.join!(@uri).to_s.should == "http://example.com:80/"
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com/" do
    @uri.should == Addressable::URI.parse("http://example.com/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com:/" do
    @uri.should == Addressable::URI.parse("http://example.com:/")
  end

  # Section 6.2.3 of RFC 3986
  it "should be equal to http://example.com:80/" do
    @uri.should == Addressable::URI.parse("http://example.com:80/")
  end

  # Section 6.2.2.1 of RFC 3986
  it "should be equal to http://EXAMPLE.COM/" do
    @uri.should == Addressable::URI.parse("http://EXAMPLE.COM/")
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => 80,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com:8080/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com:8080/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com:8080'" do
    @uri.authority.should == "example.com:8080"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 8080" do
    @uri.port.should == 8080
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should be exactly equal to http://example.com:8080/" do
    @uri.eql?(Addressable::URI.parse(
      "http://example.com:8080/")).should == true
  end

  it "should have a route of 'http://example.com:8080/' from " +
      "'http://example.com/path/to/'" do
    @uri.route_from("http://example.com/path/to/").should ==
      Addressable::URI.parse("http://example.com:8080/")
  end

  it "should have a route of 'http://example.com:8080/' from " +
      "'http://example.com:80/path/to/'" do
    @uri.route_from("http://example.com:80/path/to/").should ==
      Addressable::URI.parse("http://example.com:8080/")
  end

  it "should have a route of '/' from " +
      "'http://example.com:8080/path/to/'" do
    @uri.route_from("http://example.com:8080/path/to/").should ==
      Addressable::URI.parse("/")
  end

  it "should have a route of 'http://example.com:8080/' from " +
      "'http://user:pass@example.com/path/to/'" do
    @uri.route_from("http://user:pass@example.com/path/to/").should ==
      Addressable::URI.parse("http://example.com:8080/")
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => 8080,
      :path => "/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com:8080'" do
    @uri.origin.should == 'http://example.com:8080'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com:%38%30/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com:%38%30/")
  end

  it "should have the correct port" do
    @uri.port.should == 80
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.should === "http://example.com/"
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/..'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/..")
  end

  it "should have the correct port" do
    @uri.inferred_port.should == 80
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.should === "http://example.com/"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/../..'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/../..")
  end

  it "should have the correct port" do
    @uri.inferred_port.should == 80
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.should === "http://example.com/"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/path/to/resource/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/path/to/resource/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/path/to/resource/'" do
    @uri.path.should == "/path/to/resource/"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should not be considered relative" do
    @uri.should_not be_relative
  end

  it "should be exactly equal to http://example.com:8080/" do
    @uri.eql?(Addressable::URI.parse(
      "http://example.com/path/to/resource/")).should == true
  end

  it "should have a route of 'resource/' from " +
      "'http://example.com/path/to/'" do
    @uri.route_from("http://example.com/path/to/").should ==
      Addressable::URI.parse("resource/")
  end

  it "should have a route of 'resource/' from " +
      "'http://example.com:80/path/to/'" do
    @uri.route_from("http://example.com:80/path/to/").should ==
      Addressable::URI.parse("resource/")
  end

  it "should have a route of 'http://example.com/path/to/' from " +
      "'http://example.com:8080/path/to/'" do
    @uri.route_from("http://example.com:8080/path/to/").should ==
      Addressable::URI.parse("http://example.com/path/to/resource/")
  end

  it "should have a route of 'http://example.com/path/to/' from " +
      "'http://user:pass@example.com/path/to/'" do
    @uri.route_from("http://user:pass@example.com/path/to/").should ==
      Addressable::URI.parse("http://example.com/path/to/resource/")
  end

  it "should have a route of '/path/to/resource/' from " +
      "'http://example.com/to/resource/'" do
    @uri.route_from("http://example.com/to/resource/").should ==
      Addressable::URI.parse("/path/to/resource/")
  end

  it "should correctly convert to a hash" do
    @uri.to_hash.should == {
      :scheme => "http",
      :user => nil,
      :password => nil,
      :host => "example.com",
      :port => nil,
      :path => "/path/to/resource/",
      :query => nil,
      :fragment => nil
    }
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end
end

describe Addressable::URI, "when parsed from " +
    "'relative/path/to/resource'" do
  before do
    @uri = Addressable::URI.parse("relative/path/to/resource")
  end

  it "should not have a scheme" do
    @uri.scheme.should == nil
  end

  it "should not be considered ip-based" do
    @uri.should_not be_ip_based
  end

  it "should not have an authority segment" do
    @uri.authority.should == nil
  end

  it "should not have a host" do
    @uri.host.should == nil
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should not have a port" do
    @uri.port.should == nil
  end

  it "should have a path of 'relative/path/to/resource'" do
    @uri.path.should == "relative/path/to/resource"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should not be considered absolute" do
    @uri.should_not be_absolute
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should raise an error if routing is attempted" do
    (lambda do
      @uri.route_to("http://example.com/")
    end).should raise_error(ArgumentError, /relative\/path\/to\/resource/)
    (lambda do
      @uri.route_from("http://example.com/")
    end).should raise_error(ArgumentError, /relative\/path\/to\/resource/)
  end

  it "when joined with 'another/relative/path' should be " +
      "'relative/path/to/another/relative/path'" do
    @uri.join('another/relative/path').should ==
      Addressable::URI.parse("relative/path/to/another/relative/path")
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end
end

describe Addressable::URI, "when parsed from " +
    "'relative_path_with_no_slashes'" do
  before do
    @uri = Addressable::URI.parse("relative_path_with_no_slashes")
  end

  it "should not have a scheme" do
    @uri.scheme.should == nil
  end

  it "should not be considered ip-based" do
    @uri.should_not be_ip_based
  end

  it "should not have an authority segment" do
    @uri.authority.should == nil
  end

  it "should not have a host" do
    @uri.host.should == nil
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should not have a port" do
    @uri.port.should == nil
  end

  it "should have a path of 'relative_path_with_no_slashes'" do
    @uri.path.should == "relative_path_with_no_slashes"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should not be considered absolute" do
    @uri.should_not be_absolute
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "when joined with 'another_relative_path' should be " +
      "'another_relative_path'" do
    @uri.join('another_relative_path').should ==
      Addressable::URI.parse("another_relative_path")
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/file.txt'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/file.txt")
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/file.txt'" do
    @uri.path.should == "/file.txt"
  end

  it "should have a basename of 'file.txt'" do
    @uri.basename.should == "file.txt"
  end

  it "should have an extname of '.txt'" do
    @uri.extname.should == ".txt"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/file.txt;parameter'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/file.txt;parameter")
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/file.txt;parameter'" do
    @uri.path.should == "/file.txt;parameter"
  end

  it "should have a basename of 'file.txt'" do
    @uri.basename.should == "file.txt"
  end

  it "should have an extname of '.txt'" do
    @uri.extname.should == ".txt"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/file.txt;x=y'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/file.txt;x=y")
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end

  it "should have a scheme of 'http'" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'example.com'" do
    @uri.authority.should == "example.com"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have no username" do
    @uri.user.should == nil
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/file.txt;x=y'" do
    @uri.path.should == "/file.txt;x=y"
  end

  it "should have an extname of '.txt'" do
    @uri.extname.should == ".txt"
  end

  it "should have no query string" do
    @uri.query.should == nil
  end

  it "should have no fragment" do
    @uri.fragment.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'svn+ssh://developername@rubyforge.org/var/svn/project'" do
  before do
    @uri = Addressable::URI.parse(
      "svn+ssh://developername@rubyforge.org/var/svn/project"
    )
  end

  it "should have a scheme of 'svn+ssh'" do
    @uri.scheme.should == "svn+ssh"
  end

  it "should be considered to be ip-based" do
    @uri.should be_ip_based
  end

  it "should have a path of '/var/svn/project'" do
    @uri.path.should == "/var/svn/project"
  end

  it "should have a username of 'developername'" do
    @uri.user.should == "developername"
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'ssh+svn://developername@RUBYFORGE.ORG/var/svn/project'" do
  before do
    @uri = Addressable::URI.parse(
      "ssh+svn://developername@RUBYFORGE.ORG/var/svn/project"
    )
  end

  it "should have a scheme of 'ssh+svn'" do
    @uri.scheme.should == "ssh+svn"
  end

  it "should have a normalized scheme of 'svn+ssh'" do
    @uri.normalized_scheme.should == "svn+ssh"
  end

  it "should have a normalized site of 'svn+ssh'" do
    @uri.normalized_site.should == "svn+ssh://developername@rubyforge.org"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of '/var/svn/project'" do
    @uri.path.should == "/var/svn/project"
  end

  it "should have a username of 'developername'" do
    @uri.user.should == "developername"
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should not be considered to be in normal form" do
    @uri.normalize.should_not be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'mailto:user@example.com'" do
  before do
    @uri = Addressable::URI.parse("mailto:user@example.com")
  end

  it "should have a scheme of 'mailto'" do
    @uri.scheme.should == "mailto"
  end

  it "should not be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of 'user@example.com'" do
    @uri.path.should == "user@example.com"
  end

  it "should have no user" do
    @uri.user.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'tag:example.com,2006-08-18:/path/to/something'" do
  before do
    @uri = Addressable::URI.parse(
      "tag:example.com,2006-08-18:/path/to/something")
  end

  it "should have a scheme of 'tag'" do
    @uri.scheme.should == "tag"
  end

  it "should be considered to be ip-based" do
    @uri.should_not be_ip_based
  end

  it "should have a path of " +
      "'example.com,2006-08-18:/path/to/something'" do
    @uri.path.should == "example.com,2006-08-18:/path/to/something"
  end

  it "should have no user" do
    @uri.user.should == nil
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/x;y/'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/x;y/")
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?x=1&y=2'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?x=1&y=2")
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end
end

describe Addressable::URI, "when parsed from " +
    "'view-source:http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("view-source:http://example.com/")
  end

  it "should have a scheme of 'view-source'" do
    @uri.scheme.should == "view-source"
  end

  it "should have a path of 'http://example.com/'" do
    @uri.path.should == "http://example.com/"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://user:pass@example.com/path/to/resource?query=x#fragment'" do
  before do
    @uri = Addressable::URI.parse(
      "http://user:pass@example.com/path/to/resource?query=x#fragment")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have an authority segment of 'user:pass@example.com'" do
    @uri.authority.should == "user:pass@example.com"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have a password of 'pass'" do
    @uri.password.should == "pass"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/path/to/resource'" do
    @uri.path.should == "/path/to/resource"
  end

  it "should have a query string of 'query=x'" do
    @uri.query.should == "query=x"
  end

  it "should have a fragment of 'fragment'" do
    @uri.fragment.should == "fragment"
  end

  it "should be considered to be in normal form" do
    @uri.normalize.should be_eql(@uri)
  end

  it "should have a route of '/path/' to " +
      "'http://user:pass@example.com/path/'" do
    @uri.route_to("http://user:pass@example.com/path/").should ==
      Addressable::URI.parse("/path/")
  end

  it "should have a route of '/path/to/resource?query=x#fragment' " +
      "from 'http://user:pass@example.com/path/'" do
    @uri.route_from("http://user:pass@example.com/path/").should ==
      Addressable::URI.parse("to/resource?query=x#fragment")
  end

  it "should have a route of '?query=x#fragment' " +
      "from 'http://user:pass@example.com/path/to/resource'" do
    @uri.route_from("http://user:pass@example.com/path/to/resource").should ==
      Addressable::URI.parse("?query=x#fragment")
  end

  it "should have a route of '#fragment' " +
      "from 'http://user:pass@example.com/path/to/resource?query=x'" do
    @uri.route_from(
      "http://user:pass@example.com/path/to/resource?query=x").should ==
        Addressable::URI.parse("#fragment")
  end

  it "should have a route of '#fragment' from " +
      "'http://user:pass@example.com/path/to/resource?query=x#fragment'" do
    @uri.route_from(
      "http://user:pass@example.com/path/to/resource?query=x#fragment"
    ).should == Addressable::URI.parse("#fragment")
  end

  it "should have a route of 'http://elsewhere.com/' to " +
      "'http://elsewhere.com/'" do
    @uri.route_to("http://elsewhere.com/").should ==
      Addressable::URI.parse("http://elsewhere.com/")
  end

  it "should have a route of " +
      "'http://user:pass@example.com/path/to/resource?query=x#fragment' " +
      "from 'http://example.com/path/to/'" do
    @uri.route_from("http://elsewhere.com/path/to/").should ==
      Addressable::URI.parse(
        "http://user:pass@example.com/path/to/resource?query=x#fragment")
  end

  it "should have the correct scheme after assignment" do
    @uri.scheme = "ftp"
    @uri.scheme.should == "ftp"
    @uri.to_s.should ==
      "ftp://user:pass@example.com/path/to/resource?query=x#fragment"
    @uri.to_str.should ==
      "ftp://user:pass@example.com/path/to/resource?query=x#fragment"
    @uri.scheme = "bogus!"
    @uri.scheme.should == "bogus!"
    @uri.normalized_scheme.should == "bogus%21"
    @uri.normalize.to_s.should ==
      "bogus%21://user:pass@example.com/path/to/resource?query=x#fragment"
    @uri.normalize.to_str.should ==
      "bogus%21://user:pass@example.com/path/to/resource?query=x#fragment"
  end

  it "should have the correct site segment after assignment" do
    @uri.site = "https://newuser:newpass@example.com:443"
    @uri.scheme.should == "https"
    @uri.authority.should == "newuser:newpass@example.com:443"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.normalized_userinfo.should == "newuser:newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 443
    @uri.inferred_port.should == 443
    @uri.to_s.should ==
      "https://newuser:newpass@example.com:443" +
      "/path/to/resource?query=x#fragment"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser:newpass@example.com:80"
    @uri.authority.should == "newuser:newpass@example.com:80"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.normalized_userinfo.should == "newuser:newpass"
    @uri.host.should == "example.com"
    @uri.port.should == 80
    @uri.inferred_port.should == 80
    @uri.to_s.should ==
      "http://newuser:newpass@example.com:80" +
      "/path/to/resource?query=x#fragment"
  end

  it "should have the correct userinfo segment after assignment" do
    @uri.userinfo = "newuser:newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.authority.should == "newuser:newpass@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should ==
      "http://newuser:newpass@example.com" +
      "/path/to/resource?query=x#fragment"
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.authority.should == "newuser:pass@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.authority.should == "user:newpass@example.com"
  end

  it "should have the correct host after assignment" do
    @uri.host = "newexample.com"
    @uri.host.should == "newexample.com"
    @uri.authority.should == "user:pass@newexample.com"
  end

  it "should have the correct port after assignment" do
    @uri.port = 8080
    @uri.port.should == 8080
    @uri.authority.should == "user:pass@example.com:8080"
  end

  it "should have the correct path after assignment" do
    @uri.path = "/newpath/to/resource"
    @uri.path.should == "/newpath/to/resource"
    @uri.to_s.should ==
      "http://user:pass@example.com/newpath/to/resource?query=x#fragment"
  end

  it "should have the correct scheme and authority after nil assignment" do
    @uri.site = nil
    @uri.scheme.should == nil
    @uri.authority.should == nil
    @uri.to_s.should == "/path/to/resource?query=x#fragment"
  end

  it "should have the correct scheme and authority after assignment" do
    @uri.site = "file://"
    @uri.scheme.should == "file"
    @uri.authority.should == ""
    @uri.to_s.should == "file:///path/to/resource?query=x#fragment"
  end

  it "should have the correct path after nil assignment" do
    @uri.path = nil
    @uri.path.should == ""
    @uri.to_s.should ==
      "http://user:pass@example.com?query=x#fragment"
  end

  it "should have the correct query string after assignment" do
    @uri.query = "newquery=x"
    @uri.query.should == "newquery=x"
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource?newquery=x#fragment"
    @uri.query = nil
    @uri.query.should == nil
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource#fragment"
  end

  it "should have the correct query string after hash assignment" do
    @uri.query_values = {"?uestion mark"=>"=sign", "hello"=>"g\xC3\xBCnther"}
    @uri.query.split("&").should include("%3Fuestion%20mark=%3Dsign")
    @uri.query.split("&").should include("hello=g%C3%BCnther")
    @uri.query_values.should == {
      "?uestion mark"=>"=sign", "hello"=>"g\xC3\xBCnther"
    }
  end

  it "should have the correct query string after flag hash assignment" do
    @uri.query_values = {'flag?1' => true, 'fl=ag2' => true, 'flag3' => true}
    @uri.query.split("&").should include("flag%3F1")
    @uri.query.split("&").should include("fl%3Dag2")
    @uri.query.split("&").should include("flag3")
    @uri.query_values.should == {
      'flag?1' => true, 'fl=ag2' => true, 'flag3' => true
    }
  end

  it "should raise an error if query values are set to a bogus type" do
    (lambda do
      @uri.query_values = "bogus"
    end).should raise_error(TypeError)
  end

  it "should have the correct fragment after assignment" do
    @uri.fragment = "newfragment"
    @uri.fragment.should == "newfragment"
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x#newfragment"

    @uri.fragment = nil
    @uri.fragment.should == nil
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:fragment => "newfragment").to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x#newfragment"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:fragment => nil).to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:userinfo => "newuser:newpass").to_s.should ==
      "http://newuser:newpass@example.com/path/to/resource?query=x#fragment"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:userinfo => nil).to_s.should ==
      "http://example.com/path/to/resource?query=x#fragment"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:path => "newpath").to_s.should ==
      "http://user:pass@example.com/newpath?query=x#fragment"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:port => "42", :path => "newpath", :query => "").to_s.should ==
      "http://user:pass@example.com:42/newpath?#fragment"
  end

  it "should have the correct values after a merge" do
    @uri.merge(:authority => "foo:bar@baz:42").to_s.should ==
      "http://foo:bar@baz:42/path/to/resource?query=x#fragment"
    # Ensure the operation was not destructive
    @uri.to_s.should ==
      "http://user:pass@example.com/path/to/resource?query=x#fragment"
  end

  it "should have the correct values after a destructive merge" do
    @uri.merge!(:authority => "foo:bar@baz:42")
    # Ensure the operation was destructive
    @uri.to_s.should ==
      "http://foo:bar@baz:42/path/to/resource?query=x#fragment"
  end

  it "should fail to merge with bogus values" do
    (lambda do
      @uri.merge(:port => "bogus")
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should fail to merge with bogus values" do
    (lambda do
      @uri.merge(:authority => "bar@baz:bogus")
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should fail to merge with bogus parameters" do
    (lambda do
      @uri.merge(42)
    end).should raise_error(TypeError)
  end

  it "should fail to merge with bogus parameters" do
    (lambda do
      @uri.merge("http://example.com/")
    end).should raise_error(TypeError)
  end

  it "should fail to merge with both authority and subcomponents" do
    (lambda do
      @uri.merge(:authority => "foo:bar@baz:42", :port => "42")
    end).should raise_error(ArgumentError)
  end

  it "should fail to merge with both userinfo and subcomponents" do
    (lambda do
      @uri.merge(:userinfo => "foo:bar", :user => "foo")
    end).should raise_error(ArgumentError)
  end

  it "should be identical to its duplicate" do
    @uri.should == @uri.dup
  end

  it "should have an origin of 'http://example.com'" do
    @uri.origin.should == 'http://example.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?q&&x=b'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q&&x=b")
  end

  it "should have a query of 'q&&x=b'" do
    @uri.query.should == "q&&x=b"
  end

  it "should have query_values of {'q' => true, 'x' => 'b'}" do
    @uri.query_values.should == {'q' => true, 'x' => 'b'}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?q=a+b'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q=a+b")
  end

  it "should have a query of 'q=a+b'" do
    @uri.query.should == "q=a+b"
  end

  it "should have query_values of {'q' => 'a b'}" do
    @uri.query_values.should == {'q' => 'a b'}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?q=a%2bb'" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q=a%2bb")
  end

  it "should have a query of 'q=a+b'" do
    @uri.query.should == "q=a%2bb"
  end

  it "should have query_values of {'q' => 'a+b'}" do
    @uri.query_values.should == {'q' => 'a+b'}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/?q='" do
  before do
    @uri = Addressable::URI.parse("http://example.com/?q=")
  end

  it "should have a query of 'q='" do
    @uri.query.should == "q="
  end

  it "should have query_values of {'q' => ''}" do
    @uri.query_values.should == {'q' => ''}
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://user@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://user@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have no password" do
    @uri.password.should == nil
  end

  it "should have a userinfo of 'user'" do
    @uri.userinfo.should == "user"
  end

  it "should have a normalized userinfo of 'user'" do
    @uri.normalized_userinfo.should == "user"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.to_s.should == "http://newuser@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.to_s.should == "http://user:newpass@example.com"
  end

  it "should have the correct userinfo segment after assignment" do
    @uri.userinfo = "newuser:newpass"
    @uri.userinfo.should == "newuser:newpass"
    @uri.user.should == "newuser"
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://newuser:newpass@example.com"
  end

  it "should have the correct userinfo segment after nil assignment" do
    @uri.userinfo = nil
    @uri.userinfo.should == nil
    @uri.user.should == nil
    @uri.password.should == nil
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser@example.com"
    @uri.authority.should == "newuser@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == nil
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://newuser@example.com"
  end

  it "should raise an error after nil assignment of authority segment" do
    (lambda do
      # This would create an invalid URI
      @uri.authority = nil
    end).should raise_error
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://user:@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://user:@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of 'user'" do
    @uri.user.should == "user"
  end

  it "should have a password of ''" do
    @uri.password.should == ""
  end

  it "should have a normalized userinfo of 'user:'" do
    @uri.normalized_userinfo.should == "user:"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.to_s.should == "http://user:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = "newuser:@example.com"
    @uri.authority.should == "newuser:@example.com"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://newuser:@example.com"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://:pass@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://:pass@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of ''" do
    @uri.user.should == ""
  end

  it "should have a password of 'pass'" do
    @uri.password.should == "pass"
  end

  it "should have a userinfo of ':pass'" do
    @uri.userinfo.should == ":pass"
  end

  it "should have a normalized userinfo of ':pass'" do
    @uri.normalized_userinfo.should == ":pass"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == "pass"
    @uri.to_s.should == "http://newuser:pass@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = ":newpass@example.com"
    @uri.authority.should == ":newpass@example.com"
    @uri.user.should == ""
    @uri.password.should == "newpass"
    @uri.host.should == "example.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://:newpass@example.com"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://:@example.com'" do
  before do
    @uri = Addressable::URI.parse("http://:@example.com")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a username of ''" do
    @uri.user.should == ""
  end

  it "should have a password of ''" do
    @uri.password.should == ""
  end

  it "should have a normalized userinfo of nil" do
    @uri.normalized_userinfo.should == nil
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have the correct username after assignment" do
    @uri.user = "newuser"
    @uri.user.should == "newuser"
    @uri.password.should == ""
    @uri.to_s.should == "http://newuser:@example.com"
  end

  it "should have the correct password after assignment" do
    @uri.password = "newpass"
    @uri.password.should == "newpass"
    @uri.user.should == ""
    @uri.to_s.should == "http://:newpass@example.com"
  end

  it "should have the correct authority segment after assignment" do
    @uri.authority = ":@newexample.com"
    @uri.authority.should == ":@newexample.com"
    @uri.user.should == ""
    @uri.password.should == ""
    @uri.host.should == "newexample.com"
    @uri.port.should == nil
    @uri.inferred_port.should == 80
    @uri.to_s.should == "http://:@newexample.com"
  end
end

describe Addressable::URI, "when parsed from " +
    "'#example'" do
  before do
    @uri = Addressable::URI.parse("#example")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have a host of nil" do
    @uri.host.should == nil
  end

  it "should have a site of nil" do
    @uri.site.should == nil
  end

  it "should have a normalized_site of nil" do
    @uri.normalized_site.should == nil
  end

  it "should have a path of ''" do
    @uri.path.should == ""
  end

  it "should have a query string of nil" do
    @uri.query.should == nil
  end

  it "should have a fragment of 'example'" do
    @uri.fragment.should == "example"
  end
end

describe Addressable::URI, "when parsed from " +
    "the network-path reference '//example.com/'" do
  before do
    @uri = Addressable::URI.parse("//example.com/")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should have a path of '/'" do
    @uri.path.should == "/"
  end

  it "should raise an error if routing is attempted" do
    (lambda do
      @uri.route_to("http://example.com/")
    end).should raise_error(ArgumentError, /\/\/example.com\//)
    (lambda do
      @uri.route_from("http://example.com/")
    end).should raise_error(ArgumentError, /\/\/example.com\//)
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'feed://http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("feed://http://example.com/")
  end

  it "should have a host of 'http'" do
    @uri.host.should == "http"
  end

  it "should have a path of '//example.com/'" do
    @uri.path.should == "//example.com/"
  end
end

describe Addressable::URI, "when parsed from " +
    "'feed:http://example.com/'" do
  before do
    @uri = Addressable::URI.parse("feed:http://example.com/")
  end

  it "should have a path of 'http://example.com/'" do
    @uri.path.should == "http://example.com/"
  end

  it "should normalize to 'http://example.com/'" do
    @uri.normalize.to_s.should == "http://example.com/"
    @uri.normalize!.to_s.should == "http://example.com/"
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'example://a/b/c/%7Bfoo%7D'" do
  before do
    @uri = Addressable::URI.parse("example://a/b/c/%7Bfoo%7D")
  end

  # Section 6.2.2 of RFC 3986
  it "should be equivalent to eXAMPLE://a/./b/../b/%63/%7bfoo%7d" do
    @uri.should ==
      Addressable::URI.parse("eXAMPLE://a/./b/../b/%63/%7bfoo%7d")
  end

  it "should have an origin of 'example://a'" do
    @uri.origin.should == 'example://a'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://example.com/indirect/path/./to/../resource/'" do
  before do
    @uri = Addressable::URI.parse(
      "http://example.com/indirect/path/./to/../resource/")
  end

  it "should use the 'http' scheme" do
    @uri.scheme.should == "http"
  end

  it "should have a host of 'example.com'" do
    @uri.host.should == "example.com"
  end

  it "should use port 80" do
    @uri.inferred_port.should == 80
  end

  it "should have a path of '/indirect/path/./to/../resource/'" do
    @uri.path.should == "/indirect/path/./to/../resource/"
  end

  # Section 6.2.2.3 of RFC 3986
  it "should have a normalized path of '/indirect/path/resource/'" do
    @uri.normalize.path.should == "/indirect/path/resource/"
    @uri.normalize!.path.should == "/indirect/path/resource/"
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://under_score.example.com/'" do
  it "should not cause an error" do
    (lambda do
      Addressable::URI.parse("http://under_score.example.com/")
    end).should_not raise_error
  end
end

describe Addressable::URI, "when parsed from " +
    "'./this:that'" do
  before do
    @uri = Addressable::URI.parse("./this:that")
  end

  it "should be considered relative" do
    @uri.should be_relative
  end

  it "should have no scheme" do
    @uri.scheme.should == nil
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from " +
    "'this:that'" do
  before do
    @uri = Addressable::URI.parse("this:that")
  end

  it "should be considered absolute" do
    @uri.should be_absolute
  end

  it "should have a scheme of 'this'" do
    @uri.scheme.should == "this"
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from '?'" do
  before do
    @uri = Addressable::URI.parse("?")
  end

  it "should have the correct subscript notation query values" do
    @uri.query_values.should == {}
    @uri.query_values(:notation => :subscript).should == {}
  end

  it "should have the correct dot notation query values" do
    @uri.query_values(:notation => :dot).should == {}
  end

  it "should have the correct flat notation query values" do
    @uri.query_values(:notation => :flat).should == {}
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from '?one=1&two=2&three=3'" do
  before do
    @uri = Addressable::URI.parse("?one=1&two=2&three=3")
  end

  it "should have the correct query values" do
    @uri.query_values.should == {"one" => "1", "two" => "2", "three" => "3"}
  end

  it "should raise an error for invalid query value notations" do
    (lambda do
      @uri.query_values(:notation => :bogus)
    end).should raise_error(ArgumentError)
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one", "1"], ["two", "2"], ["three", "3"]
    ]
  end

  it "should have a 'null' origin" do
    @uri.origin.should == 'null'
  end
end

describe Addressable::URI, "when parsed from '?one=1=uno&two=2=dos'" do
  before do
    @uri = Addressable::URI.parse("?one=1=uno&two=2=dos")
  end

  it "should have the correct query values" do
    @uri.query_values.should == {"one" => "1=uno", "two" => "2=dos"}
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one", "1=uno"], ["two", "2=dos"]
    ]
  end
end

describe Addressable::URI, "when parsed from '?one[two][three]=four'" do
  before do
    @uri = Addressable::URI.parse("?one[two][three]=four")
  end

  it "should have the correct query values" do
    @uri.query_values.should == {"one" => {"two" => {"three" => "four"}}}
  end

  it "should have the correct flat notation query values" do
    @uri.query_values(:notation => :flat).should == {
      "one[two][three]" => "four"
    }
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one[two][three]", "four"]
    ]
  end
end

describe Addressable::URI, "when parsed from '?one.two.three=four'" do
  before do
    @uri = Addressable::URI.parse("?one.two.three=four")
  end

  it "should have the correct dot notation query values" do
    @uri.query_values(:notation => :dot).should == {
      "one" => {"two" => {"three" => "four"}}
    }
  end

  it "should have the correct flat notation query values" do
    @uri.query_values(:notation => :flat).should == {
      "one.two.three" => "four"
    }
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one.two.three", "four"]
    ]
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one[two][three]=four&one[two][five]=six'" do
  before do
    @uri = Addressable::URI.parse("?one[two][three]=four&one[two][five]=six")
  end

  it "should have the correct dot notation query values" do
    @uri.query_values(:notation => :subscript).should == {
      "one" => {"two" => {"three" => "four", "five" => "six"}}
    }
  end

  it "should have the correct flat notation query values" do
    @uri.query_values(:notation => :flat).should == {
      "one[two][three]" => "four",
      "one[two][five]" => "six"
    }
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one[two][three]", "four"], ["one[two][five]", "six"]
    ]
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one.two.three=four&one.two.five=six'" do
  before do
    @uri = Addressable::URI.parse("?one.two.three=four&one.two.five=six")
  end

  it "should have the correct dot notation query values" do
    @uri.query_values(:notation => :dot).should == {
      "one" => {"two" => {"three" => "four", "five" => "six"}}
    }
  end

  it "should have the correct flat notation query values" do
    @uri.query_values(:notation => :flat).should == {
      "one.two.three" => "four",
      "one.two.five" => "six"
    }
  end

  it "should have the correct flat array notation query values" do
    @uri.query_values(:notation => :flat_array).should == [
      ["one.two.three", "four"], ["one.two.five", "six"]
    ]
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one=two&one=three'" do
  before do
    @uri = Addressable::URI.parse(
      "?one=two&one=three"
    )
  end

  it "should have correct flat_array notation query values" do
    @uri.query_values(:notation => :flat_array).should ==
      [['one', 'two'], ['one', 'three']]
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one[two][three][]=four&one[two][three][]=five'" do
  before do
    @uri = Addressable::URI.parse(
      "?one[two][three][]=four&one[two][three][]=five"
    )
  end

  it "should have the correct subscript notation query values" do
    @uri.query_values(:notation => :subscript).should == {
      "one" => {"two" => {"three" => ["four", "five"]}}
    }
  end

  it "should raise an error if a key is repeated in the flat notation" do
    (lambda do
      @uri.query_values(:notation => :flat)
    end).should raise_error(ArgumentError)
  end

  it "should not raise an error if a key is " +
      "repeated in the flat array notation" do
    (lambda do
      @uri.query_values(:notation => :flat_array)
    end).should_not raise_error
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one[two][three][0]=four&one[two][three][1]=five'" do
  before do
    @uri = Addressable::URI.parse(
      "?one[two][three][0]=four&one[two][three][1]=five"
    )
  end

  it "should have the correct subscript notation query values" do
    @uri.query_values(:notation => :subscript).should == {
      "one" => {"two" => {"three" => ["four", "five"]}}
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one[two][three][1]=four&one[two][three][0]=five'" do
  before do
    @uri = Addressable::URI.parse(
      "?one[two][three][1]=four&one[two][three][0]=five"
    )
  end

  it "should have the correct subscript notation query values" do
    @uri.query_values(:notation => :subscript).should == {
      "one" => {"two" => {"three" => ["five", "four"]}}
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'?one[two][three][2]=four&one[two][three][1]=five'" do
  before do
    @uri = Addressable::URI.parse(
      "?one[two][three][2]=four&one[two][three][1]=five"
    )
  end

  it "should have the correct subscript notation query values" do
    @uri.query_values(:notation => :subscript).should == {
      "one" => {"two" => {"three" => ["five", "four"]}}
    }
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://www.詹姆斯.com/'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/")
  end

  it "should be equivalent to 'http://www.xn--8ws00zhy3a.com/'" do
    @uri.should ==
      Addressable::URI.parse("http://www.xn--8ws00zhy3a.com/")
  end

  it "should not have domain name encoded during normalization" do
    Addressable::URI.normalized_encode(@uri.to_s).should ==
      "http://www.詹姆斯.com/"
  end

  it "should have an origin of 'http://www.xn--8ws00zhy3a.com'" do
    @uri.origin.should == 'http://www.xn--8ws00zhy3a.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://www.詹姆斯.com/ some spaces /'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/ some spaces /")
  end

  it "should be equivalent to " +
      "'http://www.xn--8ws00zhy3a.com/%20some%20spaces%20/'" do
    @uri.should ==
      Addressable::URI.parse(
        "http://www.xn--8ws00zhy3a.com/%20some%20spaces%20/")
  end

  it "should not have domain name encoded during normalization" do
    Addressable::URI.normalized_encode(@uri.to_s).should ==
      "http://www.詹姆斯.com/%20some%20spaces%20/"
  end

  it "should have an origin of 'http://www.xn--8ws00zhy3a.com'" do
    @uri.origin.should == 'http://www.xn--8ws00zhy3a.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://www.xn--8ws00zhy3a.com/'" do
  before do
    @uri = Addressable::URI.parse("http://www.xn--8ws00zhy3a.com/")
  end

  it "should be displayed as http://www.詹姆斯.com/" do
    @uri.display_uri.to_s.should == "http://www.詹姆斯.com/"
  end

  it "should properly force the encoding" do
    display_string = @uri.display_uri.to_str
    display_string.should == "http://www.詹姆斯.com/"
    if display_string.respond_to?(:encoding)
      display_string.encoding.to_s.should == Encoding::UTF_8.to_s
    end
  end

  it "should have an origin of 'http://www.xn--8ws00zhy3a.com'" do
    @uri.origin.should == 'http://www.xn--8ws00zhy3a.com'
  end
end

describe Addressable::URI, "when parsed from " +
    "'http://www.詹姆斯.com/atomtests/iri/詹.html'" do
  before do
    @uri = Addressable::URI.parse("http://www.詹姆斯.com/atomtests/iri/詹.html")
  end

  it "should normalize to " +
      "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html" do
    @uri.normalize.to_s.should ==
      "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html"
    @uri.normalize!.to_s.should ==
      "http://www.xn--8ws00zhy3a.com/atomtests/iri/%E8%A9%B9.html"
  end
end

describe Addressable::URI, "when parsed from a percent-encoded IRI" do
  before do
    @uri = Addressable::URI.parse(
      "http://www.%E3%81%BB%E3%82%93%E3%81%A8%E3%81%86%E3%81%AB%E3%81%AA" +
      "%E3%81%8C%E3%81%84%E3%82%8F%E3%81%91%E3%81%AE%E3%82%8F%E3%81%8B%E3" +
      "%82%89%E3%81%AA%E3%81%84%E3%81%A9%E3%82%81%E3%81%84%E3%82%93%E3%82" +
      "%81%E3%81%84%E3%81%AE%E3%82%89%E3%81%B9%E3%82%8B%E3%81%BE%E3%81%A0" +
      "%E3%81%AA%E3%81%8C%E3%81%8F%E3%81%97%E3%81%AA%E3%81%84%E3%81%A8%E3" +
      "%81%9F%E3%82%8A%E3%81%AA%E3%81%84.w3.mag.keio.ac.jp"
    )
  end

  it "should normalize to something sane" do
    @uri.normalize.to_s.should ==
      "http://www.xn--n8jaaaaai5bhf7as8fsfk3jnknefdde3f" +
      "g11amb5gzdb4wi9bya3kc6lra.w3.mag.keio.ac.jp/"
    @uri.normalize!.to_s.should ==
      "http://www.xn--n8jaaaaai5bhf7as8fsfk3jnknefdde3f" +
      "g11amb5gzdb4wi9bya3kc6lra.w3.mag.keio.ac.jp/"
  end

  it "should have the correct origin" do
    @uri.origin.should == (
      "http://www.xn--n8jaaaaai5bhf7as8fsfk3jnknefdde3f" +
      "g11amb5gzdb4wi9bya3kc6lra.w3.mag.keio.ac.jp"
    )
  end
end

describe Addressable::URI, "with a base uri of 'http://a/b/c/d;p?q'" do
  before do
    @uri = Addressable::URI.parse("http://a/b/c/d;p?q")
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g:h' should resolve to g:h" do
    (@uri + "g:h").to_s.should == "g:h"
    Addressable::URI.join(@uri, "g:h").to_s.should == "g:h"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g' should resolve to http://a/b/c/g" do
    (@uri + "g").to_s.should == "http://a/b/c/g"
    Addressable::URI.join(@uri.to_s, "g").to_s.should == "http://a/b/c/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with './g' should resolve to http://a/b/c/g" do
    (@uri + "./g").to_s.should == "http://a/b/c/g"
    Addressable::URI.join(@uri.to_s, "./g").to_s.should == "http://a/b/c/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g/' should resolve to http://a/b/c/g/" do
    (@uri + "g/").to_s.should == "http://a/b/c/g/"
    Addressable::URI.join(@uri.to_s, "g/").to_s.should == "http://a/b/c/g/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '/g' should resolve to http://a/g" do
    (@uri + "/g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/g").to_s.should == "http://a/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '//g' should resolve to http://g" do
    (@uri + "//g").to_s.should == "http://g"
    Addressable::URI.join(@uri.to_s, "//g").to_s.should == "http://g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '?y' should resolve to http://a/b/c/d;p?y" do
    (@uri + "?y").to_s.should == "http://a/b/c/d;p?y"
    Addressable::URI.join(@uri.to_s, "?y").to_s.should == "http://a/b/c/d;p?y"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g?y' should resolve to http://a/b/c/g?y" do
    (@uri + "g?y").to_s.should == "http://a/b/c/g?y"
    Addressable::URI.join(@uri.to_s, "g?y").to_s.should == "http://a/b/c/g?y"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '#s' should resolve to http://a/b/c/d;p?q#s" do
    (@uri + "#s").to_s.should == "http://a/b/c/d;p?q#s"
    Addressable::URI.join(@uri.to_s, "#s").to_s.should ==
      "http://a/b/c/d;p?q#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g#s' should resolve to http://a/b/c/g#s" do
    (@uri + "g#s").to_s.should == "http://a/b/c/g#s"
    Addressable::URI.join(@uri.to_s, "g#s").to_s.should == "http://a/b/c/g#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g?y#s' should resolve to http://a/b/c/g?y#s" do
    (@uri + "g?y#s").to_s.should == "http://a/b/c/g?y#s"
    Addressable::URI.join(
      @uri.to_s, "g?y#s").to_s.should == "http://a/b/c/g?y#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with ';x' should resolve to http://a/b/c/;x" do
    (@uri + ";x").to_s.should == "http://a/b/c/;x"
    Addressable::URI.join(@uri.to_s, ";x").to_s.should == "http://a/b/c/;x"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g;x' should resolve to http://a/b/c/g;x" do
    (@uri + "g;x").to_s.should == "http://a/b/c/g;x"
    Addressable::URI.join(@uri.to_s, "g;x").to_s.should == "http://a/b/c/g;x"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with 'g;x?y#s' should resolve to http://a/b/c/g;x?y#s" do
    (@uri + "g;x?y#s").to_s.should == "http://a/b/c/g;x?y#s"
    Addressable::URI.join(
      @uri.to_s, "g;x?y#s").to_s.should == "http://a/b/c/g;x?y#s"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '' should resolve to http://a/b/c/d;p?q" do
    (@uri + "").to_s.should == "http://a/b/c/d;p?q"
    Addressable::URI.join(@uri.to_s, "").to_s.should == "http://a/b/c/d;p?q"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '.' should resolve to http://a/b/c/" do
    (@uri + ".").to_s.should == "http://a/b/c/"
    Addressable::URI.join(@uri.to_s, ".").to_s.should == "http://a/b/c/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with './' should resolve to http://a/b/c/" do
    (@uri + "./").to_s.should == "http://a/b/c/"
    Addressable::URI.join(@uri.to_s, "./").to_s.should == "http://a/b/c/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '..' should resolve to http://a/b/" do
    (@uri + "..").to_s.should == "http://a/b/"
    Addressable::URI.join(@uri.to_s, "..").to_s.should == "http://a/b/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../' should resolve to http://a/b/" do
    (@uri + "../").to_s.should == "http://a/b/"
    Addressable::URI.join(@uri.to_s, "../").to_s.should == "http://a/b/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../g' should resolve to http://a/b/g" do
    (@uri + "../g").to_s.should == "http://a/b/g"
    Addressable::URI.join(@uri.to_s, "../g").to_s.should == "http://a/b/g"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../..' should resolve to http://a/" do
    (@uri + "../..").to_s.should == "http://a/"
    Addressable::URI.join(@uri.to_s, "../..").to_s.should == "http://a/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../../' should resolve to http://a/" do
    (@uri + "../../").to_s.should == "http://a/"
    Addressable::URI.join(@uri.to_s, "../../").to_s.should == "http://a/"
  end

  # Section 5.4.1 of RFC 3986
  it "when joined with '../../g' should resolve to http://a/g" do
    (@uri + "../../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '../../../g' should resolve to http://a/g" do
    (@uri + "../../../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../../../g").to_s.should == "http://a/g"
  end

  it "when joined with '../.././../g' should resolve to http://a/g" do
    (@uri + "../.././../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "../.././../g").to_s.should ==
      "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '../../../../g' should resolve to http://a/g" do
    (@uri + "../../../../g").to_s.should == "http://a/g"
    Addressable::URI.join(
      @uri.to_s, "../../../../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '/./g' should resolve to http://a/g" do
    (@uri + "/./g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/./g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '/../g' should resolve to http://a/g" do
    (@uri + "/../g").to_s.should == "http://a/g"
    Addressable::URI.join(@uri.to_s, "/../g").to_s.should == "http://a/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g.' should resolve to http://a/b/c/g." do
    (@uri + "g.").to_s.should == "http://a/b/c/g."
    Addressable::URI.join(@uri.to_s, "g.").to_s.should == "http://a/b/c/g."
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '.g' should resolve to http://a/b/c/.g" do
    (@uri + ".g").to_s.should == "http://a/b/c/.g"
    Addressable::URI.join(@uri.to_s, ".g").to_s.should == "http://a/b/c/.g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g..' should resolve to http://a/b/c/g.." do
    (@uri + "g..").to_s.should == "http://a/b/c/g.."
    Addressable::URI.join(@uri.to_s, "g..").to_s.should == "http://a/b/c/g.."
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with '..g' should resolve to http://a/b/c/..g" do
    (@uri + "..g").to_s.should == "http://a/b/c/..g"
    Addressable::URI.join(@uri.to_s, "..g").to_s.should == "http://a/b/c/..g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with './../g' should resolve to http://a/b/g" do
    (@uri + "./../g").to_s.should == "http://a/b/g"
    Addressable::URI.join(@uri.to_s, "./../g").to_s.should == "http://a/b/g"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with './g/.' should resolve to http://a/b/c/g/" do
    (@uri + "./g/.").to_s.should == "http://a/b/c/g/"
    Addressable::URI.join(@uri.to_s, "./g/.").to_s.should == "http://a/b/c/g/"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g/./h' should resolve to http://a/b/c/g/h" do
    (@uri + "g/./h").to_s.should == "http://a/b/c/g/h"
    Addressable::URI.join(@uri.to_s, "g/./h").to_s.should == "http://a/b/c/g/h"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g/../h' should resolve to http://a/b/c/h" do
    (@uri + "g/../h").to_s.should == "http://a/b/c/h"
    Addressable::URI.join(@uri.to_s, "g/../h").to_s.should == "http://a/b/c/h"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g;x=1/./y' " +
      "should resolve to http://a/b/c/g;x=1/y" do
    (@uri + "g;x=1/./y").to_s.should == "http://a/b/c/g;x=1/y"
    Addressable::URI.join(
      @uri.to_s, "g;x=1/./y").to_s.should == "http://a/b/c/g;x=1/y"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g;x=1/../y' should resolve to http://a/b/c/y" do
    (@uri + "g;x=1/../y").to_s.should == "http://a/b/c/y"
    Addressable::URI.join(
      @uri.to_s, "g;x=1/../y").to_s.should == "http://a/b/c/y"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g?y/./x' " +
      "should resolve to http://a/b/c/g?y/./x" do
    (@uri + "g?y/./x").to_s.should == "http://a/b/c/g?y/./x"
    Addressable::URI.join(
      @uri.to_s, "g?y/./x").to_s.should == "http://a/b/c/g?y/./x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g?y/../x' " +
      "should resolve to http://a/b/c/g?y/../x" do
    (@uri + "g?y/../x").to_s.should == "http://a/b/c/g?y/../x"
    Addressable::URI.join(
      @uri.to_s, "g?y/../x").to_s.should == "http://a/b/c/g?y/../x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g#s/./x' " +
      "should resolve to http://a/b/c/g#s/./x" do
    (@uri + "g#s/./x").to_s.should == "http://a/b/c/g#s/./x"
    Addressable::URI.join(
      @uri.to_s, "g#s/./x").to_s.should == "http://a/b/c/g#s/./x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'g#s/../x' " +
      "should resolve to http://a/b/c/g#s/../x" do
    (@uri + "g#s/../x").to_s.should == "http://a/b/c/g#s/../x"
    Addressable::URI.join(
      @uri.to_s, "g#s/../x").to_s.should == "http://a/b/c/g#s/../x"
  end

  # Section 5.4.2 of RFC 3986
  it "when joined with 'http:g' should resolve to http:g" do
    (@uri + "http:g").to_s.should == "http:g"
    Addressable::URI.join(@uri.to_s, "http:g").to_s.should == "http:g"
  end

  # Edge case to be sure
  it "when joined with '//example.com/' should " +
      "resolve to http://example.com/" do
    (@uri + "//example.com/").to_s.should == "http://example.com/"
    Addressable::URI.join(
      @uri.to_s, "//example.com/").to_s.should == "http://example.com/"
  end

  it "when joined with a bogus object a TypeError should be raised" do
    (lambda do
      Addressable::URI.join(@uri, 42)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when converting the path " +
    "'relative/path/to/something'" do
  before do
    @path = 'relative/path/to/something'
  end

  it "should convert to " +
      "\'relative/path/to/something\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "relative/path/to/something"
  end

  it "should join with an absolute file path correctly" do
    @base = Addressable::URI.convert_path("/absolute/path/")
    @uri = Addressable::URI.convert_path(@path)
    (@base + @uri).to_str.should ==
      "file:///absolute/path/relative/path/to/something"
  end
end

describe Addressable::URI, "when converting a bogus path" do
  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.convert_path(42)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when given a UNIX root directory" do
  before do
    @path = "/"
  end

  it "should convert to \'file:///\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given a Windows root directory" do
  before do
    @path = "C:\\"
  end

  it "should convert to \'file:///c:/\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path '/home/user/'" do
  before do
    @path = '/home/user/'
  end

  it "should convert to " +
      "\'file:///home/user/\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///home/user/"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path " +
    "'c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path " +
    "'file://c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "file://c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path " +
    "'file:c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "file:c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path " +
    "'file:/c:\\windows\\My Documents 100%20\\foo.txt'" do
  before do
    @path = "file:/c:\\windows\\My Documents 100%20\\foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given the path " +
    "'file:///c|/windows/My%20Documents%20100%20/foo.txt'" do
  before do
    @path = "file:///c|/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should convert to " +
      "\'file:///c:/windows/My%20Documents%20100%20/foo.txt\'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "file:///c:/windows/My%20Documents%20100%20/foo.txt"
  end

  it "should have an origin of 'file://'" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.origin.should == 'file://'
  end
end

describe Addressable::URI, "when given an http protocol URI" do
  before do
    @path = "http://example.com/"
  end

  it "should not do any conversion at all" do
    @uri = Addressable::URI.convert_path(@path)
    @uri.to_str.should == "http://example.com/"
  end
end

class SuperString
  def initialize(string)
    @string = string.to_s
  end

  def to_str
    return @string
  end
end

describe Addressable::URI, "when parsing a non-String object" do
  it "should correctly parse anything with a 'to_str' method" do
    Addressable::URI.parse(SuperString.new(42))
  end

  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.parse(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into String.")
  end

  it "should correctly parse heuristically anything with a 'to_str' method" do
    Addressable::URI.heuristic_parse(SuperString.new(42))
  end

  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.heuristic_parse(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into String.")
  end
end

describe Addressable::URI, "when form encoding a hash" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.form_encode(
      {"&one" => "/1", "=two" => "?2", ":three" => "#3"}
    ).should == "%26one=%2F1&%3Dtwo=%3F2&%3Athree=%233"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.form_encode(
      {"q" => "one two three"}
    ).should == "q=one+two+three"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.form_encode(
      {"key" => nil}
    ).should == "key="
  end

  it "should result in correctly encoded newlines" do
    Addressable::URI.form_encode(
      {"text" => "one\ntwo\rthree\r\nfour\n\r"}
    ).should == "text=one%0D%0Atwo%0D%0Athree%0D%0Afour%0D%0A%0D%0A"
  end

  it "should result in a sorted percent encoded sequence" do
    Addressable::URI.form_encode(
      [["a", "1"], ["dup", "3"], ["dup", "2"]], true
    ).should == "a=1&dup=2&dup=3"
  end
end

describe Addressable::URI, "when form encoding a non-Array object" do
  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.form_encode(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into Array.")
  end
end

describe Addressable::URI, "when form unencoding a string" do
  it "should result in correct values" do
    Addressable::URI.form_unencode(
      "%26one=%2F1&%3Dtwo=%3F2&%3Athree=%233"
    ).should == [["&one", "/1"], ["=two", "?2"], [":three", "#3"]]
  end

  it "should result in correct values" do
    Addressable::URI.form_unencode(
      "q=one+two+three"
    ).should == [["q", "one two three"]]
  end

  it "should result in correct values" do
    Addressable::URI.form_unencode(
      "text=one%0D%0Atwo%0D%0Athree%0D%0Afour%0D%0A%0D%0A"
    ).should == [["text", "one\ntwo\nthree\nfour\n\n"]]
  end

  it "should result in correct values" do
    Addressable::URI.form_unencode(
      "a=1&dup=2&dup=3"
    ).should == [["a", "1"], ["dup", "2"], ["dup", "3"]]
  end

  it "should result in correct values" do
    Addressable::URI.form_unencode(
      "key"
    ).should == [["key", nil]]
  end

  it "should result in correct values" do
    Addressable::URI.form_unencode("GivenName=Ren%C3%A9").should ==
      [["GivenName", "René"]]
  end
end

describe Addressable::URI, "when form unencoding a non-String object" do
  it "should correctly parse anything with a 'to_str' method" do
    Addressable::URI.form_unencode(SuperString.new(42))
  end

  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.form_unencode(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into String.")
  end
end

describe Addressable::URI, "when normalizing a non-String object" do
  it "should correctly parse anything with a 'to_str' method" do
    Addressable::URI.normalize_component(SuperString.new(42))
  end

  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.normalize_component(42)
    end).should raise_error(TypeError, "Can't convert Fixnum into String.")
  end

  it "should raise a TypeError for objects than cannot be converted" do
    (lambda do
      Addressable::URI.normalize_component("component", 42)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when normalizing a path with an encoded slash" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.parse("/path%2Fsegment/").normalize.path.should ==
      "/path%2Fsegment/"
  end
end

describe Addressable::URI, "when normalizing a partially encoded string" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component(
      "partially % encoded%21"
    ).should == "partially%20%25%20encoded!"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component(
      "partially %25 encoded!"
    ).should == "partially%20%25%20encoded!"
  end
end

describe Addressable::URI, "when normalizing a unicode sequence" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component(
      "/C%CC%A7"
    ).should == "/%C3%87"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component(
      "/%C3%87"
    ).should == "/%C3%87"
  end
end

describe Addressable::URI, "when normalizing a multibyte string" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component("günther").should ==
      "g%C3%BCnther"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.normalize_component("g%C3%BCnther").should ==
      "g%C3%BCnther"
  end
end

describe Addressable::URI, "when encoding a multibyte string" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.encode_component("günther").should == "g%C3%BCnther"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.encode_component(
      "günther", /[^a-zA-Z0-9\:\/\?\#\[\]\@\!\$\&\'\(\)\*\+\,\;\=\-\.\_\~]/
    ).should == "g%C3%BCnther"
  end
end

describe Addressable::URI, "when form encoding a multibyte string" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.form_encode({"GivenName" => "René"}).should ==
      "GivenName=Ren%C3%A9"
  end
end

describe Addressable::URI, "when encoding a string with ASCII chars 0-15" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.encode_component("one\ntwo").should == "one%0Atwo"
  end

  it "should result in correct percent encoded sequence" do
    Addressable::URI.encode_component(
      "one\ntwo", /[^a-zA-Z0-9\:\/\?\#\[\]\@\!\$\&\'\(\)\*\+\,\;\=\-\.\_\~]/
    ).should == "one%0Atwo"
  end
end

describe Addressable::URI, "when unencoding a multibyte string" do
  it "should result in correct percent encoded sequence" do
    Addressable::URI.unencode_component("g%C3%BCnther").should == "günther"
  end

  it "should result in correct percent encoded sequence as a URI" do
    Addressable::URI.unencode(
      "/path?g%C3%BCnther", ::Addressable::URI
    ).should == Addressable::URI.new(
      :path => "/path", :query => "günther"
    )
  end
end

describe Addressable::URI, "when unencoding a bogus object" do
  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.unencode_component(42)
    end).should raise_error(TypeError)
  end

  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.unencode("/path?g%C3%BCnther", Integer)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when encoding a bogus object" do
  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.encode(42)
    end).should raise_error(TypeError)
  end

  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.normalized_encode(42)
    end).should raise_error(TypeError)
  end

  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.encode_component("günther", 42)
    end).should raise_error(TypeError)
  end

  it "should raise a TypeError" do
    (lambda do
      Addressable::URI.encode_component(42)
    end).should raise_error(TypeError)
  end
end

describe Addressable::URI, "when given the input " +
    "'http://example.com/'" do
  before do
    @input = "http://example.com/"
  end

  it "should heuristically parse to 'http://example.com/'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com/"
  end
end


describe Addressable::URI, "when given the input " +
    "'http:example.com/'" do
  before do
    @input = "http:example.com/"
  end

  it "should heuristically parse to 'http://example.com/'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com/"
  end

  it "should heuristically parse to 'http://example.com/' " +
      "even with a scheme hint of 'ftp'" do
    @uri = Addressable::URI.heuristic_parse(@input, {:scheme => 'ftp'})
    @uri.to_s.should == "http://example.com/"
  end
end

describe Addressable::URI, "when given the input " +
    "'http://example.com/example.com/'" do
  before do
    @input = "http://example.com/example.com/"
  end

  it "should heuristically parse to 'http://example.com/example.com/'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com/example.com/"
  end
end

describe Addressable::URI, "when given the input " +
    "'/path/to/resource'" do
  before do
    @input = "/path/to/resource"
  end

  it "should heuristically parse to '/path/to/resource'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "/path/to/resource"
  end
end

describe Addressable::URI, "when given the input " +
    "'relative/path/to/resource'" do
  before do
    @input = "relative/path/to/resource"
  end

  it "should heuristically parse to 'relative/path/to/resource'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "relative/path/to/resource"
  end
end

describe Addressable::URI, "when given the input " +
    "'example.com'" do
  before do
    @input = "example.com"
  end

  it "should heuristically parse to 'http://example.com'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com"
  end
end

describe Addressable::URI, "when given the input " +
    "'example.com' and a scheme hint of 'ftp'" do
  before do
    @input = "example.com"
    @hints = {:scheme => 'ftp'}
  end

  it "should heuristically parse to 'http://example.com'" do
    @uri = Addressable::URI.heuristic_parse(@input, @hints)
    @uri.to_s.should == "ftp://example.com"
  end
end

describe Addressable::URI, "when given the input " +
    "'example.com:21' and a scheme hint of 'ftp'" do
  before do
    @input = "example.com:21"
    @hints = {:scheme => 'ftp'}
  end

  it "should heuristically parse to 'http://example.com:21'" do
    @uri = Addressable::URI.heuristic_parse(@input, @hints)
    @uri.to_s.should == "ftp://example.com:21"
  end
end

describe Addressable::URI, "when given the input " +
    "'example.com/path/to/resource'" do
  before do
    @input = "example.com/path/to/resource"
  end

  it "should heuristically parse to 'http://example.com/path/to/resource'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com/path/to/resource"
  end
end

describe Addressable::URI, "when given the input " +
    "'http:///example.com'" do
  before do
    @input = "http:///example.com"
  end

  it "should heuristically parse to 'http://example.com'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "http://example.com"
  end
end

describe Addressable::URI, "when given the input " +
    "'feed:///example.com'" do
  before do
    @input = "feed:///example.com"
  end

  it "should heuristically parse to 'feed://example.com'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "feed://example.com"
  end
end

describe Addressable::URI, "when given the input " +
    "'file://path/to/resource/'" do
  before do
    @input = "file://path/to/resource/"
  end

  it "should heuristically parse to 'file:///path/to/resource/'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "file:///path/to/resource/"
  end
end

describe Addressable::URI, "when given the input " +
    "'feed://http://example.com'" do
  before do
    @input = "feed://http://example.com"
  end

  it "should heuristically parse to 'feed:http://example.com'" do
    @uri = Addressable::URI.heuristic_parse(@input)
    @uri.to_s.should == "feed:http://example.com"
  end
end

describe Addressable::URI, "when assigning query values" do
  before do
    @uri = Addressable::URI.new
  end

  it "should correctly assign {:a => 'a', :b => ['c', 'd', 'e']}" do
    @uri.query_values = {:a => "a", :b => ["c", "d", "e"]}
    @uri.query.should == "a=a&b[0]=c&b[1]=d&b[2]=e"
  end

  it "should correctly assign " +
      "{:a => 'a', :b => [{:c => 'c', :d => 'd'}, {:e => 'e', :f => 'f'}]}" do
    @uri.query_values = {
      :a => "a", :b => [{:c => "c", :d => "d"}, {:e => "e", :f => "f"}]
    }
    @uri.query.should == "a=a&b[0][c]=c&b[0][d]=d&b[1][e]=e&b[1][f]=f"
  end

  it "should correctly assign " +
      "{:a => 'a', :b => [{:c => true, :d => 'd'}, {:e => 'e', :f => 'f'}]}" do
    @uri.query_values = {
      :a => 'a', :b => [{:c => true, :d => 'd'}, {:e => 'e', :f => 'f'}]
    }
    @uri.query.should == "a=a&b[0][c]&b[0][d]=d&b[1][e]=e&b[1][f]=f"
  end

  it "should correctly assign " +
      "{:a => 'a', :b => {:c => true, :d => 'd'}}" do
    @uri.query_values = {
      :a => 'a', :b => {:c => true, :d => 'd'}
    }
    @uri.query.should == "a=a&b[c]&b[d]=d"
  end

  it "should correctly assign " +
      "{:a => 'a', :b => {:c => true, :d => 'd'}, :e => []}" do
    @uri.query_values = {
      :a => 'a', :b => {:c => true, :d => 'd'}
    }
    @uri.query.should == "a=a&b[c]&b[d]=d"
  end

  it "should correctly assign {}" do
    @uri.query_values = {}
    @uri.query.should == ''
  end

  it "should correctly assign nil" do
    @uri.query_values = nil
    @uri.query.should == nil
  end

  it "should correctly sort {'ab' => 'c', :ab => 'a', :a => 'x'}" do
    @uri.query_values = {'ab' => 'c', :ab => 'a', :a => 'x'}
    @uri.query.should == "a=x&ab=a&ab=c"
  end

  it "should correctly assign " +
      "[['b', 'c'], ['b', 'a'], ['a', 'a']]" do
    # Order can be guaranteed in this format, so preserve it.
    @uri.query_values = [['b', 'c'], ['b', 'a'], ['a', 'a']]
    @uri.query.should == "b=c&b=a&a=a"
  end

  it "should preserve query string order" do
    query_string = (('a'..'z').to_a.shuffle.map { |e| "#{e}=#{e}" }).join("&")
    @uri.query = query_string
    original_uri = @uri.to_s
    @uri.query_values = @uri.query_values(:notation => :flat_array)
    @uri.to_s.should == original_uri
  end
end

describe Addressable::URI, "when assigning path values" do
  before do
    @uri = Addressable::URI.new
  end

  it "should correctly assign paths containing colons" do
    @uri.path = "acct:bob@sporkmonger.com"
    Addressable::URI.parse(@uri.normalize.to_str).path.should == @uri.path
    @uri.normalize.to_str.should == "acct%2Fbob@sporkmonger.com"
  end

  it "should correctly assign paths containing colons" do
    @uri.path = "/acct:bob@sporkmonger.com"
    @uri.authority = "example.com"
    @uri.normalize.to_str.should == "//example.com/acct:bob@sporkmonger.com"
  end

  it "should correctly assign paths containing colons" do
    @uri.path = "acct:bob@sporkmonger.com"
    @uri.scheme = "something"
    @uri.normalize.to_str.should == "something:acct:bob@sporkmonger.com"
  end

  it "should not allow relative paths to be assigned on absolute URIs" do
    (lambda do
      @uri.scheme = "http"
      @uri.host = "example.com"
      @uri.path = "acct:bob@sporkmonger.com"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should not allow relative paths to be assigned on absolute URIs" do
    (lambda do
      @uri.path = "acct:bob@sporkmonger.com"
      @uri.scheme = "http"
      @uri.host = "example.com"
    end).should raise_error(Addressable::URI::InvalidURIError)
  end

  it "should not allow relative paths to be assigned on absolute URIs" do
    (lambda do
      @uri.path = "uuid:0b3ecf60-3f93-11df-a9c3-001f5bfffe12"
      @uri.scheme = "urn"
    end).should_not raise_error(Addressable::URI::InvalidURIError)
  end
end
