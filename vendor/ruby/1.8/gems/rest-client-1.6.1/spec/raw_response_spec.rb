require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

describe RestClient::RawResponse do
  before do
    @tf = mock("Tempfile", :read => "the answer is 42", :open => true)
    @net_http_res = mock('net http response')
    @response = RestClient::RawResponse.new(@tf, @net_http_res, {})
  end

  it "behaves like string" do
    @response.to_s.should == 'the answer is 42'
  end

  it "exposes a Tempfile" do
    @response.file.should == @tf
  end
end
