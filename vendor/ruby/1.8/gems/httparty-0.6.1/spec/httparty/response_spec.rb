require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe HTTParty::Response do
  before do
    @last_modified = Date.new(2010, 1, 15).to_s
    @content_length = '1024'
    @response_object = {'foo' => 'bar'}
    @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    @response_object.stub(:body => "{foo:'bar'}")
    @response_object['last-modified'] = @last_modified
    @response_object['content-length'] = @content_length
    @parsed_response = {"foo" => "bar"}
    @response = HTTParty::Response.new(@response_object, @parsed_response)
  end

  describe "initialization" do
    it "should set the Net::HTTP Response" do
      @response.response.should == @response_object
    end

    it "should set body" do
      @response.body.should == @response_object.body
    end

    it "should set code" do
      @response.code.should.to_s == @response_object.code
    end

    it "should set code as a Fixnum" do
      @response.code.should be_an_instance_of(Fixnum)
    end
  end

  it "returns response headers" do
    response = HTTParty::Response.new(@response_object, @parsed_response)
    response.headers.should == {'last-modified' => [@last_modified], 'content-length' => [@content_length]}
  end

  it "should send missing methods to delegate" do
    response = HTTParty::Response.new(@response_object, {'foo' => 'bar'})
    response['foo'].should == 'bar'
  end

  it "should be able to iterate if it is array" do
    response = HTTParty::Response.new(@response_object, [{'foo' => 'bar'}, {'foo' => 'baz'}])
    response.size.should == 2
    expect {
      response.each { |item| }
    }.to_not raise_error
  end

  it "allows headers to be accessed by mixed-case names in hash notation" do
    response = HTTParty::Response.new(@response_object, @parsed_response)
    response.headers['Content-LENGTH'].should == @content_length
  end

  it "returns a comma-delimited value when multiple values exist" do
    @response_object.add_field 'set-cookie', 'csrf_id=12345; path=/'
    @response_object.add_field 'set-cookie', '_github_ses=A123CdE; path=/'
    response = HTTParty::Response.new(@response_object, @parsed_response)
    response.headers['set-cookie'].should == "csrf_id=12345; path=/, _github_ses=A123CdE; path=/"
  end

  # Backwards-compatibility - previously, #headers returned a Hash
  it "responds to hash methods" do
    response = HTTParty::Response.new(@response_object, @parsed_response)
    hash_methods = {}.methods - response.headers.methods
    hash_methods.each do |method_name|
      response.headers.respond_to?(method_name).should be_true
    end
  end

  xit "should allow hashes to be accessed with dot notation" do
    response = HTTParty::Response.new({'foo' => 'bar'}, "{foo:'bar'}", 200, 'OK')
    response.foo.should == 'bar'
  end

  xit "should allow nested hashes to be accessed with dot notation" do
    response = HTTParty::Response.new({'foo' => {'bar' => 'baz'}}, "{foo: {bar:'baz'}}", 200, 'OK')
    response.foo.should == {'bar' => 'baz'}
    response.foo.bar.should == 'baz'
  end
end
