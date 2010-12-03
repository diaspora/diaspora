#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MessageHandler do
  let(:message_body) {"I want to pump you up"} 
  let(:message_urls) {["http://www.google.com/", "http://yahoo.com/", "http://foo.com/"]}

  describe 'POST messages' do
    before do
      @num_tries = MessageHandler::NUM_TRIES
    end
    it 'enqueues a POST' do
      Resque.should_receive(:enqueue).with(Jobs::HttpPost, message_urls.first, message_body, @num_tries)
      MessageHandler.add_post_request(message_urls.first, message_body)
    end

    it 'enqueues multiple POSTs' do
      message_urls.each do |url|
        Resque.should_receive(:enqueue).with(Jobs::HttpPost, url, message_body, @num_tries).once
      end
      MessageHandler.add_post_request(message_urls, message_body)
    end
  end
end
