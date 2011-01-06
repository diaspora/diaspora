#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PubSubHubbub do
  before :all do
    RestClient.unstub!(:post)
  end

  after :all do

    RestClient.stub!(:post).and_return(FakeHttpRequest.new(:success))
  end

  describe '#initialize' do
  end

  describe '#publish' do
    it 'posts the feed to the given hub' do
      hub = "http://hubzord.com/"
      feed = 'http://rss.com/dom.atom'
      body = {'hub.url' => feed, 'hub.mode' => 'publish'}

      stub_request(:post, "http://hubzord.com/").
        with(:body => "hub.url=http%3A%2F%2Frss.com%2Fdom.atom&headers=&hub.mode=publish", 
       :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'65', 'Content-Type'=>'application/x-www-form-urlencoded'}).to_return(:status => [202, 'you are awesome'])
      PubSubHubbub.new(hub).publish(feed).code.should == 202
    end
  end
end
