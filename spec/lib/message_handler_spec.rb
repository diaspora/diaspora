#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MessageHandler do
    before do
       unstub_mocha_stubs
    end
    after  do
      MessageHandler.any_instance.stubs(:add_post_request)
    end

  before do
    @handler = MessageHandler.new
    @message_body = "I want to pump you up"
    @message_urls = ["http://www.google.com/", "http://yahoo.com/", "http://foo.com/"]

  end

  describe 'GET messages' do
    describe 'creating a GET query' do
      it 'should be able to add a GET query to the queue with required destinations' do
        EventMachine.run{
          @handler.add_get_request(@message_urls)
          @handler.size.should == @message_urls.size
          EventMachine.stop
        }
      end

    end

    describe 'processing a GET query' do
      it 'should remove sucessful http requests from the queue' do
        request = FakeHttpRequest.new(:success)
        request.should_receive(:get).and_return(request)
        EventMachine::HttpRequest.stub!(:new).and_return(request)

        EventMachine.run {
          @handler.add_get_request("http://www.google.com/")
          @handler.size.should == 1
          @handler.process
          @handler.size.should == 0
          EventMachine.stop
        }
      end

      it 'should only retry a bad request the correct number of times' do
        request = FakeHttpRequest.new(:failure)
        request.should_receive(:get).exactly(MessageHandler::NUM_TRIES).times.and_return(request)
        EventMachine::HttpRequest.stub!(:new).and_return(request)

        EventMachine.run {
          @handler.add_get_request("http://asdfsdajfsdfbasdj.com/")
          @handler.size.should == 1
          @handler.process
          @handler.size.should == 0

        EventMachine.stop
      }
      end
    end
  end

  describe 'POST messages' do
    it 'should be able to add a post message to the queue' do
      EventMachine.run {
        @handler.size.should ==0
        @handler.add_post_request(@message_urls.first, @message_body)
        @handler.size.should == 1

        EventMachine.stop
      }
    end

    it 'should be able to insert many posts into the queue' do
      EventMachine.run {
        @handler.size.should == 0
        @handler.add_post_request(@message_urls, @message_body)
        @handler.size.should == @message_urls.size
        EventMachine.stop
      }
    end

    it 'should post a single message to a given URL' do
      request = FakeHttpRequest.new(:success)
      request.should_receive(:post).and_return(request)
      EventMachine::HttpRequest.stub!(:new).and_return(request)
      EventMachine.run{

        @handler.add_post_request(@message_urls.first, @message_body)
        @handler.size.should == 1
        @handler.process
        @handler.size.should == 0

        EventMachine.stop

      }
    end
  end

  describe "Hub publish" do
    before do
      EventMachine::PubSubHubbub.stub(:new).and_return(:success)
    end
    it 'should correctly queue up a pubsubhubbub publish request' do
      destination = "http://identi.ca/hub/"
      feed_location = "http://google.com/"

      EventMachine.run {
        @handler.add_hub_notification(destination, feed_location)
        q = @handler.instance_variable_get(:@queue)

        message = ""
        q.pop{|m| message = m}

        message.destination.should == destination
        message.body.should == feed_location

        EventMachine.stop
      }
    end
  end

  describe "Mixed Queries" do

    it 'should process both POST and GET requests in the same queue' do
      request = FakeHttpRequest.new(:success)
      request.should_receive(:get).exactly(3).times.and_return(request)
      request.should_receive(:post).exactly(3).times.and_return(request)
      EventMachine::HttpRequest.stub!(:new).and_return(request)

      EventMachine.run{
        @handler.add_post_request(@message_urls,@message_body)
        @handler.size.should == 3
        @handler.add_get_request(@message_urls)
        @handler.size.should == 6
        @handler.process
        timer = EventMachine::Timer.new(1) do
          @handler.size.should == 0
          EventMachine.stop
        end
      }
    end

    it 'should be able to have seperate POST and GET have different callbacks' do
      request = FakeHttpRequest.new(:success)
      request.should_receive(:get).exactly(1).times.and_return(request)
      request.should_receive(:post).exactly(1).times.and_return(request)

      EventMachine::HttpRequest.stub!(:new).and_return(request)

      EventMachine.run{
        @handler.add_post_request(@message_urls.first,@message_body)
        @handler.add_get_request(@message_urls.first)
        @handler.process

        EventMachine.stop
      }

    end
  end
end

