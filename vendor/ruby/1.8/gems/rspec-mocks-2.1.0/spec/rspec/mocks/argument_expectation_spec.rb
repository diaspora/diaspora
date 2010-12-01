require 'spec_helper'

module RSpec
  module Mocks
    describe ArgumentExpectation do
      it "considers an object that responds to #matches? and #description to be a matcher" do
        argument_expecatation = RSpec::Mocks::ArgumentExpectation.new
        obj = double("matcher")
        obj.should_receive(:respond_to?).with(:matches?).and_return(true)
        obj.should_receive(:respond_to?).with(:description).and_return(true)
        argument_expecatation.is_matcher?(obj).should be_true
      end

      it "does NOT consider an object that only responds to #matches? to be a matcher" do
        argument_expecatation = RSpec::Mocks::ArgumentExpectation.new
        obj = double("matcher")
        obj.should_receive(:respond_to?).with(:matches?).and_return(true)
        obj.should_receive(:respond_to?).with(:description).and_return(false)
        argument_expecatation.is_matcher?(obj).should be_false
      end
    end
  end
end
