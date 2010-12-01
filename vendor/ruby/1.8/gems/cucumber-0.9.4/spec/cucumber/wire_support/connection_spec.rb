require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe Connection do
      class TestConnection < Connection
        attr_accessor :socket
      end
      
      class TestConfiguration
        attr_reader :custom_timeout
        
        def initialize
          @custom_timeout = {}
        end
        
        def timeout(message = nil)
          return :default_timeout if message.nil?
          @custom_timeout[message] || :custom_timeout
        end
      end
      
      before(:each) do
        @config = TestConfiguration.new
        @connection = TestConnection.new(@config)
        @connection.socket = @socket = mock('socket')
        Timeout.stub(:timeout).with(:custom_timeout).and_raise(Timeout::Error.new(''))
        @response = %q{["response"]}
        Timeout.stub(:timeout).with(:default_timeout).and_return(@response)
      end
      
      it "re-raises a timeout error" do
        Timeout.stub!(:timeout).and_raise(Timeout::Error.new(''))
        lambda { @connection.call_remote(nil, :foo, []) }.should raise_error(Timeout::Error)
      end
      
      it "ignores timeout errors when configured to do so" do
        @config.custom_timeout[:foo] = :never
        @socket.should_receive(:gets).and_return(@response)
        handler = mock(:handle_response => :response)
        @connection.call_remote(handler, :foo, []).should == :response
      end
    end
  end
end
