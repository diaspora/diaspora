require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Typhoeus::NormalizedHeaderHash do
  before(:all) do
    @klass = Typhoeus::NormalizedHeaderHash
  end

  it "should normalize keys on assignment" do
    hash = @klass.new
    hash['Content-Type'] = 'text/html'
    hash['content-type'].should == 'text/html'
    hash[:content_type].should == 'text/html'
    hash['Accepts'] = 'text/javascript'
    hash['accepts'].should == 'text/javascript'
  end

  it "should normalize the keys on instantiation" do
    hash = @klass.new('Content-Type' => 'text/html', :x_http_header => 'foo', 'X-HTTP-USER' => 'bar')
    hash.keys.should =~ ['Content-Type', 'X-Http-Header', 'X-Http-User']
  end

  it "should merge keys correctly" do
    hash = @klass.new
    hash.merge!('Content-Type' => 'fdsa')
    hash['content-type'].should == 'fdsa'
  end

  it "should allow any casing of keys" do
    hash = @klass.new
    hash['Content-Type'] = 'fdsa'
    hash['content-type'].should == 'fdsa'
    hash['cOnTent-TYPE'].should == 'fdsa'
    hash['Content-Type'].should == 'fdsa'
  end

  it "should support has_key?" do
    hash = @klass.new
    hash['Content-Type'] = 'fdsa'
    hash.has_key?('cOntent-Type').should be_true
  end
end
