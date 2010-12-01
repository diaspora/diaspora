require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe WebMock::StubRequestSnippet do
  describe "to_s" do
    before(:each) do
      @request_signature = WebMock::RequestSignature.new(:get, "www.example.com/?a=b&c=d")
    end

    it "should print stub request snippet with url with params and method and empty successful response" do
      expected = %Q(stub_request(:get, "http://www.example.com/?a=b&c=d").\n  to_return(:status => 200, :body => "", :headers => {}))
      WebMock::StubRequestSnippet.new(@request_signature).to_s.should == expected
    end

    it "should print stub request snippet with body if available" do
      @request_signature.body = "abcdef"
      expected = %Q(stub_request(:get, "http://www.example.com/?a=b&c=d").)+  
      "\n  with(:body => \"abcdef\")." +
      "\n  to_return(:status => 200, :body => \"\", :headers => {})"
      WebMock::StubRequestSnippet.new(@request_signature).to_s.should == expected
    end
    
    it "should print stub request snippet with multiline body" do
      @request_signature.body = "abc\ndef"
      expected = %Q(stub_request(:get, "http://www.example.com/?a=b&c=d").)+  
      "\n  with(:body => \"abc\\ndef\")." +
      "\n  to_return(:status => 200, :body => \"\", :headers => {})"
      WebMock::StubRequestSnippet.new(@request_signature).to_s.should == expected
    end
    
    it "should print stub request snippet with headers if any" do
      @request_signature.headers = {'B' => 'b', 'A' => 'a'}
      expected = 'stub_request(:get, "http://www.example.com/?a=b&c=d").'+  
      "\n  with(:headers => {\'A\'=>\'a\', \'B\'=>\'b\'})." +
      "\n  to_return(:status => 200, :body => \"\", :headers => {})"
      WebMock::StubRequestSnippet.new(@request_signature).to_s.should == expected
    end
    
    it "should print stub request snippet with body and headers" do
      @request_signature.body = "abcdef"
      @request_signature.headers = {'B' => 'b', 'A' => 'a'}
      expected = 'stub_request(:get, "http://www.example.com/?a=b&c=d").'+  
      "\n  with(:body => \"abcdef\", \n       :headers => {\'A\'=>\'a\', \'B\'=>\'b\'})." +
      "\n  to_return(:status => 200, :body => \"\", :headers => {})"
      WebMock::StubRequestSnippet.new(@request_signature).to_s.should == expected
    end
  end
end
