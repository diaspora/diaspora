require 'spec_helper'

module RSpec
  module Mocks
    describe "a mock" do
      before(:each) do
        @mock = double("mock").as_null_object
      end
      it "answers false for received_message? when no messages received" do
        @mock.received_message?(:message).should be_false
      end
      it "answers true for received_message? when message received" do
        @mock.message
        @mock.received_message?(:message).should be_true
      end
      it "answers true for received_message? when message received with correct args" do
        @mock.message 1,2,3
        @mock.received_message?(:message, 1,2,3).should be_true
      end
      it "answers false for received_message? when message received with incorrect args" do
        @mock.message 1,2,3
        @mock.received_message?(:message, 1,2).should be_false
      end
    end
  end
end
