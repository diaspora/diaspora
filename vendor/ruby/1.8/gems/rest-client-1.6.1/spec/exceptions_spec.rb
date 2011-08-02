require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

require 'webmock/rspec'
include WebMock

describe RestClient::Exception do
  it "sets the exception message to ErrorMessage" do
    RestClient::ResourceNotFound.new.message.should == 'Resource Not Found'
  end

  it "contains exceptions in RestClient" do
    RestClient::Unauthorized.new.should be_a_kind_of(RestClient::Exception)
    RestClient::ServerBrokeConnection.new.should be_a_kind_of(RestClient::Exception)
  end
end

describe RestClient::RequestFailed do
  before do
    @response = mock('HTTP Response', :code => '502')
  end

  it "stores the http response on the exception" do
    response = "response"
    begin
      raise RestClient::RequestFailed, response
    rescue RestClient::RequestFailed => e
      e.response.should == response
    end
  end

  it "http_code convenience method for fetching the code as an integer" do
    RestClient::RequestFailed.new(@response).http_code.should == 502
  end

  it "http_body convenience method for fetching the body (decoding when necessary)" do
    RestClient::RequestFailed.new(@response).http_code.should == 502
    RestClient::RequestFailed.new(@response).message.should == 'HTTP status code 502'
  end

  it "shows the status code in the message" do
    RestClient::RequestFailed.new(@response).to_s.should match(/502/)
  end
end

describe RestClient::ResourceNotFound do
  it "also has the http response attached" do
    response = "response"
    begin
      raise RestClient::ResourceNotFound, response
    rescue RestClient::ResourceNotFound => e
      e.response.should == response
    end
  end
end

describe "backwards compatibility" do
  it "alias RestClient::Request::Redirect to RestClient::Redirect" do
    RestClient::Request::Redirect.should == RestClient::Redirect
  end

  it "alias RestClient::Request::Unauthorized to RestClient::Unauthorized" do
    RestClient::Request::Unauthorized.should == RestClient::Unauthorized
  end

  it "alias RestClient::Request::RequestFailed to RestClient::RequestFailed" do
    RestClient::Request::RequestFailed.should == RestClient::RequestFailed
  end

  it "make the exception's response act like an Net::HTTPResponse" do
    body = "body"
    stub_request(:get, "www.example.com").to_return(:body => body, :status => 404)
    begin
      RestClient.get "www.example.com"
      raise
    rescue RestClient::ResourceNotFound => e
      e.response.body.should == body
    end
  end
end
