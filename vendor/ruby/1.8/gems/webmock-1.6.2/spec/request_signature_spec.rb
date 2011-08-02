require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe WebMock::RequestSignature do

  describe "initialization" do

    it "should have assigned normalized uri" do
      WebMock::Util::URI.should_receive(:normalize_uri).and_return("www.example.kom")
      signature = WebMock::RequestSignature.new(:get, "www.example.com")
      signature.uri.should == "www.example.kom"
    end

    it "should have assigned uri without normalization if uri is URI" do
      WebMock::Util::URI.should_not_receive(:normalize_uri)
      uri = Addressable::URI.parse("www.example.com")
      signature = WebMock::RequestSignature.new(:get, uri)
      signature.uri.should == uri
    end

    it "should have assigned normalized headers" do
      WebMock::Util::Headers.should_receive(:normalize_headers).with('A' => 'a').and_return('B' => 'b')
      WebMock::RequestSignature.new(:get, "www.example.com", :headers => {'A' => 'a'}).headers.should == {'B' => 'b'}
    end

    it "should have assigned body" do
      WebMock::RequestSignature.new(:get, "www.example.com", :body => "abc").body.should == "abc"
    end

  end

  it "should report string describing itself" do
    WebMock::RequestSignature.new(:get, "www.example.com",
      :body => "abc", :headers => {'A' => 'a', 'B' => 'b'}).to_s.should ==
    "GET http://www.example.com/ with body 'abc' with headers {'A'=>'a', 'B'=>'b'}"
  end

  describe "hash" do
    it "should report same hash for two signatures with the same values" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com",
        :body => "abc", :headers => {'A' => 'a', 'B' => 'b'})
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com",
        :body => "abc", :headers => {'A' => 'a', 'B' => 'b'})
      signature1.hash.should == signature2.hash
    end

    it "should report different hash for two signatures with different method" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com")
      signature2 = WebMock::RequestSignature.new(:put, "www.example.com")
      signature1.hash.should_not == signature2.hash
    end

    it "should report different hash for two signatures with different uri" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com")
      signature2 = WebMock::RequestSignature.new(:get, "www.example.org")
      signature1.hash.should_not == signature2.hash
    end

    it "should report different hash for two signatures with different body" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com", :body => "abc")
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com", :body => "def")
      signature1.hash.should_not == signature2.hash
    end

    it "should report different hash for two signatures with different headers" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com",
        :headers => {'A' => 'a'})
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com",
        :headers => {'A' => 'A'})
      signature1.hash.should_not == signature2.hash
    end
  end


  describe "eql?" do
    it "should be true for two signatures with the same values" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com",
        :body => "abc", :headers => {'A' => 'a', 'B' => 'b'})
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com",
        :body => "abc", :headers => {'A' => 'a', 'B' => 'b'})

      signature1.should eql(signature2)
    end

    it "should be false for two signatures with different method" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com")
      signature2 = WebMock::RequestSignature.new(:put, "www.example.com")
      signature1.should_not eql(signature2)
    end

    it "should be false for two signatures with different uri" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com")
      signature2 = WebMock::RequestSignature.new(:get, "www.example.org")
      signature1.should_not eql(signature2)
    end

    it "should be false for two signatures with different body" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com", :body => "abc")
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com", :body => "def")
      signature1.should_not eql(signature2)
    end

    it "should be false for two signatures with different headers" do
      signature1 = WebMock::RequestSignature.new(:get, "www.example.com",
        :headers => {'A' => 'a'})
      signature2 = WebMock::RequestSignature.new(:get, "www.example.com",
        :headers => {'A' => 'A'})
      signature1.should_not eql(signature2)
    end
  end

end
