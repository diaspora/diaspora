require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "errors" do
  describe WebMock::NetConnectNotAllowedError do
    describe "message" do
      it "should have message with request signature and snippet" do
        request_signature = mock(:to_s => "aaa")
        WebMock::StubRequestSnippet.stub!(:new).
          with(request_signature).and_return(mock(:to_s => "bbb"))
        expected =  "Real HTTP connections are disabled. Unregistered request: aaa" +
               "\n\nYou can stub this request with the following snippet:\n\n" +
               "bbb\n\n============================================================"  
        WebMock::NetConnectNotAllowedError.new(request_signature).message.should == expected  
      end
    end
  end
end