require 'spec_helper'

describe Jobs::HttpPost do
  before do
    @url = 'example.org/things/on/fire'
    @body = '<xml>California</xml>'
    @escaped_body = CGI::escape(@body)
  end
  it 'POSTs to a given URL' do
    RestClient.should_receive(:post).with(@url, {:xml=>@escaped_body}).and_return(true)
    Jobs::HttpPost.perform(@url, @body, 3)
  end
  it 'retries' do
    RestClient.should_receive(:post).with(@url, {:xml=>@escaped_body}).and_raise(SocketError)
    Resque.should_receive(:enqueue).with(Jobs::HttpPost, @url, @escaped_body, 1).once
    Jobs::HttpPost.perform(@url, @body, 2)
  end
end
