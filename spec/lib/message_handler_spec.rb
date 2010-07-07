require File.dirname(__FILE__) + '/../spec_helper'

EventMachine.run{
describe MessageHandler do
  before do
    @handler = MessageHandler.new
    @message_body = "I want to pump you up" 
    @message_urls = ["http://www.google.com/", "http://yahoo.com/", "http://foo.com/"]
  end

  describe 'GET messages' do
    describe 'creating a GET query' do 
      
      it 'should be able to add a GET query to the queue with required destinations' do
          EM.next_tick{
          @handler.add_get_request(@message_urls)
          @handler.size.should == @message_urls.size
          }
      end

    end

    describe 'processing a GET query' do
      it 'should remove sucessful http requests from the queue' do
        EM.next_tick{
        request = FakeHttpRequest.new(:success)
        request.should_receive(:get).and_return(request)
        EventMachine::HttpRequest.stub!(:new).and_return(request)
          @handler.add_get_request("http://www.google.com/")
          @handler.size.should == 1
          @handler.process
          @handler.size.should == 0
        }
      end


      it 'should only retry a bad request three times ' do
        EM.next_tick{
        request = FakeHttpRequest.new(:failure)
        request.should_receive(:get).exactly(MessageHandler::NUM_TRIES).times.and_return(request)
        EventMachine::HttpRequest.stub!(:new).and_return(request)

          @handler.add_get_request("http://www.google.com/")
          @handler.add_get_request("http://asdfsdajfsdfbasdj.com/")
          @handler.size.should == 1
          @handler.process
          @handler.size.should == 0
        }
      end
    end
  end

  describe 'POST messages' do
    

    it 'should be able to add a post message to the queue' do
        EM.next_tick{
        @handler.size.should ==0
        @handler.add_post_request(@message_urls.first, @message_body)
        @handler.size.should == 1
        }
    end

    it 'should be able to insert many posts into the queue' do
        EM.next_tick{
        @handler.size.should == 0
        @handler.add_post_request(@message_urls, @message_body)
        @handler.size.should == @message_urls.size
        }
    end

    it 'should post a single message to a given URL' do
        EM.next_tick{
      request = FakeHttpRequest.new(:success)
      request.should_receive(:post).and_return(request)
      EventMachine::HttpRequest.stub!(:new).and_return(request)
        
        @handler.add_post_request(@message_urls.first, @message_body)
        @handler.size.should == 1
        @handler.process
        @handler.size.should == 0 
        }
    end
  end

  describe "Mixed Queries" do 
    
    it 'should process both POST and GET requests in the same queue' do
      EM.next_tick{

      request = FakeHttpRequest.new(:success)
      request.should_receive(:get).exactly(3).times.and_return(request)
      request.should_receive(:post).exactly(3).times.and_return(request)
      EventMachine::HttpRequest.stub!(:new).and_return(request)
 
        @handler.add_post_request(@message_urls,@message_body)
        @handler.size.should == 3
        @handler.add_get_request(@message_urls)
        @handler.size.should == 6
        @handler.process
        #timer = EventMachine::Timer.new(1) do
          @handler.size.should == 0
        #end
        }
    end

    it 'should be able to have seperate POST and GET have different callbacks' do
      EM.next_tick{
      request = FakeHttpRequest.new(:success)
      request.should_receive(:get).exactly(1).times.and_return(request)
      request.should_receive(:post).exactly(1).times.and_return(request)
      @handler.should_receive(:send_to_seed).once
      
      EventMachine::HttpRequest.stub!(:new).and_return(request)
        @handler.add_post_request(@message_urls.first,@message_body)
        @handler.add_get_request(@message_urls.first)
        @handler.process
      }

    end
  end
end

class FakeHttpRequest
  def initialize(callback_wanted)
    @callback = callback_wanted
  end

  def response 
    "NOTE YOU ARE IN FAKE HTTP"
  end

  def post; end
  def get; end
  def callback(&b)
    b.call if @callback == :success
  end
  def errback(&b)
    b.call if @callback == :failure
  end
end
EventMachine.stop
}
