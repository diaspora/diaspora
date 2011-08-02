require 'spec_helper'
require 'rspec/mocks'

module RSpec
  module Mocks
    describe Space do
      before :each do
        @space = RSpec::Mocks::Space.new
        klazz = Class.new do
          def rspec_verify
            @verified = true
          end
          def verified?
            @verified
          end
          def rspec_reset
            @reset = true
          end
          def reset?
            @reset
          end
        end
        @m1 = klazz.new
        @m2 = klazz.new
      end
      it "verifies all mocks within" do
        @space.add(@m1)
        @space.add(@m2)
        @space.verify_all
        @m1.should be_verified
        @m2.should be_verified
      end
      it "resets all mocks within" do
        @space.add(m1 = double("mock1"))
        @space.add(m2 = double("mock2"))
        m1.should_receive(:rspec_reset)
        m2.should_receive(:rspec_reset)
        @space.reset_all
      end
      it "clears internal mocks on reset_all" do
        @space.add(m = double("mock"))
        @space.reset_all
        @space.instance_eval { mocks.empty? }.should be_true
      end
      it "only adds an instance once" do
        @space.add(m1 = double("mock1"))
        @space.add(m1)
        m1.should_receive(:rspec_verify)
        @space.verify_all
      end
    end
  end
end
    
