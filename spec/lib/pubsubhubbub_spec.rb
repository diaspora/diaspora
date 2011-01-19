#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib', 'pubsubhubbub')

describe Pubsubhubbub do

  before do
    RestClient.unstub!(:post)
  end

  after do
    RestClient.stub!(:post).and_return(FakeHttpRequest.new(:success))
  end

  describe '#publish' do
    it 'posts the feed to the given hub' do
      hub = "http://hubzord.com/"
      feed = 'http://rss.com/dom.atom'
      body = {'hub.url' => feed, 'hub.mode' => 'publish'}

      stub_request(:post, "http://hubzord.com/").to_return(:status => [202, 'you are awesome'])
      Pubsubhubbub.new(hub).publish(feed).code.should == 202
    end
  end
end
