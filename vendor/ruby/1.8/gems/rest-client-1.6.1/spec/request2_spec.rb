require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

require 'webmock/rspec'
include WebMock

describe RestClient::Request do

  it "manage params for get requests" do
    stub_request(:get, 'http://some/resource?a=b&c=d').with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Foo'=>'bar'}).to_return(:body => 'foo', :status => 200)
    RestClient::Request.execute(:url => 'http://some/resource', :method => :get, :headers => {:foo => :bar, :params => {:a => :b, 'c' => 'd'}}).body.should == 'foo'

    stub_request(:get, 'http://some/resource').with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Foo'=>'bar', 'params' => 'a'}).to_return(:body => 'foo', :status => 200)
    RestClient::Request.execute(:url => 'http://some/resource', :method => :get, :headers => {:foo => :bar, :params => :a}).body.should == 'foo'
  end

end

