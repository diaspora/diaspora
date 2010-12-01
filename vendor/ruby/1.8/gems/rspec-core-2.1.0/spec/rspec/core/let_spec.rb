require 'spec_helper'

describe "#let" do
  let(:counter) do
    Class.new do
      def initialize
        @count = 0
      end
      def count
        @count += 1
      end
    end.new
  end

  it "generates an instance method" do
    counter.count.should == 1
  end

  it "caches the value" do
    counter.count.should == 1
    counter.count.should == 2
  end
end

describe "#let!" do
  let!(:creator) do
    class Creator
      @count = 0
      def self.count
        @count += 1
      end
    end
  end

  it "evaluates the value non-lazily" do
    lambda { Creator.count }.should_not raise_error
  end

  it "does not interfere between tests" do
    Creator.count.should == 1
  end
end
