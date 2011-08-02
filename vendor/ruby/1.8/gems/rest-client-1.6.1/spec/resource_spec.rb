require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

require 'webmock/rspec'
include WebMock

describe RestClient::Resource do
  before do
    @resource = RestClient::Resource.new('http://some/resource', :user => 'jane', :password => 'mypass', :headers => {'X-Something' => '1'})
  end

  context "Resource delegation" do
    it "GET" do
      RestClient::Request.should_receive(:execute).with(:method => :get, :url => 'http://some/resource', :headers => {'X-Something' => '1'}, :user => 'jane', :password => 'mypass')
      @resource.get
    end

    it "POST" do
      RestClient::Request.should_receive(:execute).with(:method => :post, :url => 'http://some/resource', :payload => 'abc', :headers => {:content_type => 'image/jpg', 'X-Something' => '1'}, :user => 'jane', :password => 'mypass')
      @resource.post 'abc', :content_type => 'image/jpg'
    end

    it "PUT" do
      RestClient::Request.should_receive(:execute).with(:method => :put, :url => 'http://some/resource', :payload => 'abc', :headers => {:content_type => 'image/jpg', 'X-Something' => '1'}, :user => 'jane', :password => 'mypass')
      @resource.put 'abc', :content_type => 'image/jpg'
    end

    it "DELETE" do
      RestClient::Request.should_receive(:execute).with(:method => :delete, :url => 'http://some/resource', :headers => {'X-Something' => '1'}, :user => 'jane', :password => 'mypass')
      @resource.delete
    end

    it "overrides resource headers" do
      RestClient::Request.should_receive(:execute).with(:method => :get, :url => 'http://some/resource', :headers => {'X-Something' => '2'}, :user => 'jane', :password => 'mypass')
      @resource.get 'X-Something' => '2'
    end
  end

  it "can instantiate with no user/password" do
    @resource = RestClient::Resource.new('http://some/resource')
  end

  it "is backwards compatible with previous constructor" do
    @resource = RestClient::Resource.new('http://some/resource', 'user', 'pass')
    @resource.user.should == 'user'
    @resource.password.should == 'pass'
  end

  it "concatenates urls, inserting a slash when it needs one" do
    @resource.concat_urls('http://example.com', 'resource').should == 'http://example.com/resource'
  end

  it "concatenates urls, using no slash if the first url ends with a slash" do
    @resource.concat_urls('http://example.com/', 'resource').should == 'http://example.com/resource'
  end

  it "concatenates urls, using no slash if the second url starts with a slash" do
    @resource.concat_urls('http://example.com', '/resource').should == 'http://example.com/resource'
  end

  it "concatenates even non-string urls, :posts + 1 => 'posts/1'" do
    @resource.concat_urls(:posts, 1).should == 'posts/1'
  end

  it "offers subresources via []" do
    parent = RestClient::Resource.new('http://example.com')
    parent['posts'].url.should == 'http://example.com/posts'
  end

  it "transports options to subresources" do
    parent = RestClient::Resource.new('http://example.com', :user => 'user', :password => 'password')
    parent['posts'].user.should == 'user'
    parent['posts'].password.should == 'password'
  end

  it "passes a given block to subresources" do
    block = Proc.new{|r| r}
    parent = RestClient::Resource.new('http://example.com', &block)
    parent['posts'].block.should == block
  end

  it "the block should be overrideable" do
    block1 = Proc.new{|r| r}
    block2 = Proc.new{|r| r}
    parent = RestClient::Resource.new('http://example.com', &block1)
    # parent['posts', &block2].block.should == block2 # ruby 1.9 syntax
    parent.send(:[], 'posts', &block2).block.should == block2
  end

  it "the block should be overrideable in ruby 1.9 syntax" do
    block = Proc.new{|r| r}
    parent = RestClient::Resource.new('http://example.com', &block)
    r19_syntax = %q{
      parent['posts', &->(r){r}].block.should_not == block
    }
    if is_ruby_19?
      eval(r19_syntax)
    end
  end

  it "prints its url with to_s" do
    RestClient::Resource.new('x').to_s.should == 'x'
  end

  describe 'block' do
    it 'can use block when creating the resource' do
      stub_request(:get, 'www.example.com').to_return(:body => '', :status => 404)
      resource = RestClient::Resource.new('www.example.com') { |response, request| 'foo' }
      resource.get.should == 'foo'
    end

    it 'can use block when executing the resource' do
      stub_request(:get, 'www.example.com').to_return(:body => '', :status => 404)
      resource = RestClient::Resource.new('www.example.com')
      resource.get { |response, request| 'foo' }.should == 'foo'
    end

    it 'execution block override resource block' do
      stub_request(:get, 'www.example.com').to_return(:body => '', :status => 404)
      resource = RestClient::Resource.new('www.example.com') { |response, request| 'foo' }
      resource.get { |response, request| 'bar' }.should == 'bar'
    end

  end
end
