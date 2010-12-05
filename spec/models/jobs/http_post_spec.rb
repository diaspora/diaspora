require 'spec_helper'

describe Jobs::HttpPost do
  before do
    @url = 'example.org/things/on/fire'
    @body = '<xml>California</xml>'
  end
  it 'POSTs to a given URL' do
    RestClient::Resource.should_receive(:new).with(@url, :xml=>@body, :timeout => 4)
    Jobs::HttpPost.perform(@url, @body, 3)
  end
  it 'retries' do
    RestClient::Resource.should_receive(:new).with(@url, :xml=>@body, :timeout => 4)
    Resque.should_receive(:enqueue).with(Jobs::HttpPost, @url, @body, 1).once
    Jobs::HttpPost.perform(@url, @body, 2)
  end
end
