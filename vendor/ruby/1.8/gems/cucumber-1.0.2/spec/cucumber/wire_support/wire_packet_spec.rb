require 'spec_helper'
require 'cucumber/wire_support/wire_language'

module Cucumber
  module WireSupport
    describe WirePacket do

      describe "#to_json" do
        it "should convert params to a JSON hash" do
          packet = WirePacket.new('test_message', :foo => :bar)
          packet.to_json.should == "[\"test_message\",{\"foo\":\"bar\"}]"
        end
        
        it "should not pass blank params" do
          packet = WirePacket.new('test_message')
          packet.to_json.should == "[\"test_message\"]"
        end
      end
      
      describe ".parse" do
        it "should understand a raw packet containing null parameters" do
          packet = WirePacket.parse("[\"test_message\",null]")
          packet.message.should == 'test_message'
          packet.params.should be_nil
        end

        it "should understand a raw packet containing no parameters" do
          packet = WirePacket.parse("[\"test_message\"]")
          packet.message.should == 'test_message'
          packet.params.should be_nil
        end
        
        it "should understand a raw packet containging parameters data" do
          packet = WirePacket.parse("[\"test_message\",{\"foo\":\"bar\"}]")
          packet.params['foo'].should == 'bar'
        end
      end
    end
  end
end