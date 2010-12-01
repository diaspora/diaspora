require 'spec_helper'

module RSpec
  module Matchers
    describe "[actual.should] be_close(expected, delta)" do
      before(:each) do
        RSpec.stub(:warn)
      end

      it "delegates to be_within(delta).of(expected)" do
        should_receive(:be_within).with(0.5).and_return( be_within_matcher = stub )
        be_within_matcher.should_receive(:of).with(3.0)
        be_close(3.0, 0.5)
      end

      it "prints a deprecation warning" do
        RSpec.should_receive(:warn).with(/please use be_within.*instead/)
        be_close(3.0, 0.5)
      end
    end
  end
end
