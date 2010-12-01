require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WireException do
      before(:each) do
        @host, @port = 'localhost', '54321'
      end
      def exception
        WireException.new(@data, @host, @port)
      end
      describe "with just a message" do
        before(:each) do
          @data = {'message' => 'foo'}
        end
        it "should #to_s as expected" do
          exception.to_s.should == "foo"
        end
      end
      
      describe "with a message and an exception" do
        before(:each) do
          @data = {'message' => 'foo', 'exception' => 'Bar'}
        end
        it "should #to_s as expected" do
          exception.to_s.should == "foo"
        end
        it "#class.to_s should return the name of the exception" do
          exception.class.to_s.should == 'Bar from localhost:54321'
        end
      end
      
      describe "with a custom backtrace" do
        before(:each) do
          @data = {'message' => 'foo', 'backtrace' => ['foo', 'bar', 'baz']}
        end
        it "#backrace should return the custom backtrace" do
          exception.backtrace.should == ['foo', 'bar', 'baz']
        end
      end
    end
  end
end