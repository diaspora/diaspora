require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

describe RestClient::Payload do
  context "A regular Payload" do
    it "should use standard enctype as default content-type" do
      RestClient::Payload::UrlEncoded.new({}).headers['Content-Type'].
              should == 'application/x-www-form-urlencoded'
    end

    it "should form properly encoded params" do
      RestClient::Payload::UrlEncoded.new({:foo => 'bar'}).to_s.
              should == "foo=bar"
      ["foo=bar&baz=qux", "baz=qux&foo=bar"].should include(
              RestClient::Payload::UrlEncoded.new({:foo => 'bar', :baz => 'qux'}).to_s)
    end

    it "should escape parameters" do
      RestClient::Payload::UrlEncoded.new({'foo ' => 'bar'}).to_s.
              should == "foo%20=bar"
    end

    it "should properly handle hashes as parameter" do
      RestClient::Payload::UrlEncoded.new({:foo => {:bar => 'baz' }}).to_s.
              should == "foo[bar]=baz"
      RestClient::Payload::UrlEncoded.new({:foo => {:bar => {:baz => 'qux' }}}).to_s.
              should == "foo[bar][baz]=qux"
    end

    it "should handle many attributes inside a hash" do
      parameters = RestClient::Payload::UrlEncoded.new({:foo => {:bar => 'baz', :baz => 'qux'}}).to_s
      parameters.should include("foo[bar]=baz", "foo[baz]=qux")
    end

    it "should handle attributes inside a an array inside an hash" do
      parameters = RestClient::Payload::UrlEncoded.new({"foo" => [{"bar" => 'baz'}, {"bar" => 'qux'}]}).to_s
      parameters.should include("foo[bar]=baz", "foo[bar]=qux")
    end

    it "should handle attributes inside a an array inside an array inside an hash" do
      parameters = RestClient::Payload::UrlEncoded.new({"foo" => [ [{"bar" => 'baz'}, {"bar" => 'qux'}]]}).to_s
      parameters.should include("foo[bar]=baz", "foo[bar]=qux")
    end

    it "should form properly use symbols as parameters" do
      RestClient::Payload::UrlEncoded.new({:foo => :bar}).to_s.
              should == "foo=bar"
      RestClient::Payload::UrlEncoded.new({:foo => {:bar => :baz }}).to_s.
              should == "foo[bar]=baz"
    end

    it "should properly handle arrays as repeated parameters" do
      RestClient::Payload::UrlEncoded.new({:foo => ['bar']}).to_s.
              should == "foo[]=bar"
      RestClient::Payload::UrlEncoded.new({:foo => ['bar', 'baz']}).to_s.
              should == "foo[]=bar&foo[]=baz"
    end

  end

  context "A multipart Payload" do
    it "should use standard enctype as default content-type" do
      m = RestClient::Payload::Multipart.new({})
      m.stub!(:boundary).and_return(123)
      m.headers['Content-Type'].should == 'multipart/form-data; boundary=123'
    end

    it "should form properly separated multipart data" do
      m = RestClient::Payload::Multipart.new([[:bar, "baz"], [:foo, "bar"]])
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="bar"\r
\r
baz\r
--#{m.boundary}\r
Content-Disposition: form-data; name="foo"\r
\r
bar\r
--#{m.boundary}--\r
      EOS
    end

    it "should not escape parameters names" do
      m = RestClient::Payload::Multipart.new([["bar ", "baz"]])
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="bar "\r
\r
baz\r
--#{m.boundary}--\r
      EOS
    end

    it "should form properly separated multipart data" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      m = RestClient::Payload::Multipart.new({:foo => f})
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="foo"; filename="master_shake.jpg"\r
Content-Type: image/jpeg\r
\r
#{IO.read(f.path)}\r
--#{m.boundary}--\r
      EOS
    end

    it "should ignore the name attribute when it's not set" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      m = RestClient::Payload::Multipart.new({nil => f})
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; filename="master_shake.jpg"\r
Content-Type: image/jpeg\r
\r
#{IO.read(f.path)}\r
--#{m.boundary}--\r
      EOS
    end

    it "should detect optional (original) content type and filename" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      f.instance_eval "def content_type; 'text/plain'; end"
      f.instance_eval "def original_filename; 'foo.txt'; end"
      m = RestClient::Payload::Multipart.new({:foo => f})
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="foo"; filename="foo.txt"\r
Content-Type: text/plain\r
\r
#{IO.read(f.path)}\r
--#{m.boundary}--\r
      EOS
    end

    it "should handle hash in hash parameters" do
      m = RestClient::Payload::Multipart.new({:bar => {:baz => "foo"}})
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="bar[baz]"\r
\r
foo\r
--#{m.boundary}--\r
      EOS

      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      f.instance_eval "def content_type; 'text/plain'; end"
      f.instance_eval "def original_filename; 'foo.txt'; end"
      m = RestClient::Payload::Multipart.new({:foo => {:bar => f}})
      m.to_s.should == <<-EOS
--#{m.boundary}\r
Content-Disposition: form-data; name="foo[bar]"; filename="foo.txt"\r
Content-Type: text/plain\r
\r
#{IO.read(f.path)}\r
--#{m.boundary}--\r
      EOS
    end

  end

  context "streamed payloads" do
    it "should properly determine the size of file payloads" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      payload = RestClient::Payload.generate(f)
      payload.size.should == 22_545
      payload.length.should == 22_545
    end

    it "should properly determine the size of other kinds of streaming payloads" do
      s = StringIO.new 'foo'
      payload = RestClient::Payload.generate(s)
      payload.size.should == 3
      payload.length.should == 3

      begin
        f = Tempfile.new "rest-client"
        f.write 'foo bar'

        payload = RestClient::Payload.generate(f)
        payload.size.should == 7
        payload.length.should == 7
      ensure
        f.close
      end
    end
  end

  context "Payload generation" do
    it "should recognize standard urlencoded params" do
      RestClient::Payload.generate({"foo" => 'bar'}).should be_kind_of(RestClient::Payload::UrlEncoded)
    end

    it "should recognize multipart params" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      RestClient::Payload.generate({"foo" => f}).should be_kind_of(RestClient::Payload::Multipart)
    end

    it "should be multipart if forced" do
      RestClient::Payload.generate({"foo" => "bar", :multipart => true}).should be_kind_of(RestClient::Payload::Multipart)
    end

    it "should return data if no of the above" do
      RestClient::Payload.generate("data").should be_kind_of(RestClient::Payload::Base)
    end

    it "should recognize nested multipart payloads" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      RestClient::Payload.generate({"foo" => {"file" => f}}).should be_kind_of(RestClient::Payload::Multipart)
    end

    it "should recognize file payloads that can be streamed" do
      f = File.new(File.dirname(__FILE__) + "/master_shake.jpg")
      RestClient::Payload.generate(f).should be_kind_of(RestClient::Payload::Streamed)
    end

    it "should recognize other payloads that can be streamed" do
      RestClient::Payload.generate(StringIO.new('foo')).should be_kind_of(RestClient::Payload::Streamed)
    end
  end
end
