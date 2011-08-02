require 'spec_helper'

module RSpec
  module Mocks
    describe "Example with stubbed and then called message" do
      it "fails if the message is expected and then subsequently not called again" do
        double = double("mock", :msg => nil)
        double.msg
        double.should_receive(:msg)
        lambda { double.rspec_verify }.should raise_error(RSpec::Mocks::MockExpectationError)
      end

      it "outputs arguments of all similar calls" do
        double = double('double', :foo => true)
        double.should_receive(:foo).with('first')
        double.foo('second')
        double.foo('third')
        lambda do
          double.rspec_verify
        end.should raise_error(%Q|Double "double" received :foo with unexpected arguments\n  expected: ("first")\n       got: ("second"), ("third")|)
        double.rspec_reset
      end
    end
    
  end
end
