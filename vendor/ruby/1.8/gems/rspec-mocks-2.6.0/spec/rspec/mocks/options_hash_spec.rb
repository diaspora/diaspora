require 'spec_helper'

module RSpec
  module Mocks
    describe "calling :should_receive with an options hash" do
      it "reports the file and line submitted with :expected_from" do
        begin
          mock = RSpec::Mocks::Mock.new("a mock")
          mock.should_receive(:message, :expected_from => "/path/to/blah.ext:37")
          mock.rspec_verify
        rescue Exception => e
        ensure
          e.backtrace.to_s.should =~ /\/path\/to\/blah.ext:37/m
        end
      end

      it "uses the message supplied with :message" do
        lambda {
          m = RSpec::Mocks::Mock.new("a mock")
          m.should_receive(:message, :message => "recebi nada")
          m.rspec_verify
        }.should raise_error("recebi nada")
      end
      
      it "uses the message supplied with :message after a similar stub" do
        lambda {
          m = RSpec::Mocks::Mock.new("a mock")
          m.stub(:message)
          m.should_receive(:message, :message => "from mock")
          m.rspec_verify
        }.should raise_error("from mock")
      end
    end
  end
end
