require 'spec_helper'

module BugReport496
  describe "a message expectation on a base class object" do
    class BaseClass
    end

    class SubClass < BaseClass
    end

    it "is received" do
      BaseClass.should_receive(:new).once
      SubClass.new
    end
  end
end

