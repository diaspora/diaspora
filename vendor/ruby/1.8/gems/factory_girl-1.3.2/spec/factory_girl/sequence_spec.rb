require 'spec_helper'

describe Factory::Sequence do
  describe "a sequence" do
    before do
      @sequence = Factory::Sequence.new {|n| "=#{n}" }
    end

    it "should start with a value of 1" do
      @sequence.next.should == "=1"
    end

    describe "after being called" do
      before do
        @sequence.next
      end

      it "should use the next value" do
        @sequence.next.should == "=2"
      end
    end
  end

  describe "defining a sequence" do
    before do
      @sequence = "sequence"
      @name     = :count
      stub(Factory::Sequence).new { @sequence }
    end

    it "should create a new sequence" do
      mock(Factory::Sequence).new() { @sequence }
      Factory.sequence(@name)
    end

    it "should use the supplied block as the sequence generator" do
      stub(Factory::Sequence).new.yields(1)
      yielded = false
      Factory.sequence(@name) {|n| yielded = true }
      (yielded).should be
    end
  end

  describe "after defining a sequence" do
    before do
      @sequence = "sequence"
      @name     = :test
      @value    = '1 2 5'

      stub(@sequence).next { @value }
      stub(Factory::Sequence).new { @sequence }

      Factory.sequence(@name) {}
    end

    it "should call next on the sequence when sent next" do
      mock(@sequence).next

      Factory.next(@name)
    end

    it "should return the value from the sequence" do
      Factory.next(@name).should == @value
    end
  end
end
