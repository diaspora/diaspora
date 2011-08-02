require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

describe RestClient::AbstractResponse do

  class MyAbstractResponse

    include RestClient::AbstractResponse

    attr_accessor :size

    def initialize net_http_res, args
      @net_http_res = net_http_res
      @args = args
    end

  end

  before do
    @net_http_res = mock('net http response')
    @response = MyAbstractResponse.new(@net_http_res, {})
  end

  it "fetches the numeric response code" do
    @net_http_res.should_receive(:code).and_return('200')
    @response.code.should == 200
  end

  it "has a nice description" do
    @net_http_res.should_receive(:to_hash).and_return({'Content-Type' => ['application/pdf']})
    @net_http_res.should_receive(:code).and_return('200')
    @response.description == '200 OK | application/pdf  bytes\n'
  end

  it "beautifies the headers by turning the keys to symbols" do
    h = RestClient::AbstractResponse.beautify_headers('content-type' => [ 'x' ])
    h.keys.first.should == :content_type
  end

  it "beautifies the headers by turning the values to strings instead of one-element arrays" do
    h = RestClient::AbstractResponse.beautify_headers('x' => [ 'text/html' ] )
    h.values.first.should == 'text/html'
  end

  it "fetches the headers" do
    @net_http_res.should_receive(:to_hash).and_return('content-type' => [ 'text/html' ])
    @response.headers.should == { :content_type => 'text/html' }
  end

  it "extracts cookies from response headers" do
    @net_http_res.should_receive(:to_hash).and_return('set-cookie' => ['session_id=1; path=/'])
    @response.cookies.should == { 'session_id' => '1' }
  end

  it "extract strange cookies" do
    @net_http_res.should_receive(:to_hash).and_return('set-cookie' => ['session_id=ZJ/HQVH6YE+rVkTpn0zvTQ==; path=/'])
    @response.cookies.should == { 'session_id' => 'ZJ%2FHQVH6YE+rVkTpn0zvTQ%3D%3D' }
  end

  it "doesn't escape cookies" do
    @net_http_res.should_receive(:to_hash).and_return('set-cookie' => ['session_id=BAh7BzoNYXBwX25hbWUiEGFwcGxpY2F0aW9uOgpsb2dpbiIKYWRtaW4%3D%0A--08114ba654f17c04d20dcc5228ec672508f738ca; path=/'])
    @response.cookies.should == { 'session_id' => 'BAh7BzoNYXBwX25hbWUiEGFwcGxpY2F0aW9uOgpsb2dpbiIKYWRtaW4%3D%0A--08114ba654f17c04d20dcc5228ec672508f738ca' }
  end

  it "can access the net http result directly" do
    @response.net_http_res.should == @net_http_res
  end
end
