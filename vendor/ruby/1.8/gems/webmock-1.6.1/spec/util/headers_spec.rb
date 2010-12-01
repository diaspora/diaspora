require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WebMock::Util::Headers do

  it "should decode_userinfo_from_header handles basic auth" do
    authorization_header = "Basic dXNlcm5hbWU6c2VjcmV0"
    userinfo = WebMock::Util::Headers.decode_userinfo_from_header(authorization_header)
    userinfo.should == "username:secret"
  end

  describe "sorted_headers_string" do
    
    it "should return nice string for hash with string values" do
      WebMock::Util::Headers.sorted_headers_string({"a" => "b"}).should == "{'A'=>'b'}"
    end
    
    it "should return nice string for hash with array values" do
      WebMock::Util::Headers.sorted_headers_string({"a" => ["b", "c"]}).should == "{'A'=>['b', 'c']}"
    end
  
    it "should return nice string for hash with array values and string values" do
      WebMock::Util::Headers.sorted_headers_string({"a" => ["b", "c"], "d" => "e"}).should == "{'A'=>['b', 'c'], 'D'=>'e'}"
    end
    
  
  end

end
