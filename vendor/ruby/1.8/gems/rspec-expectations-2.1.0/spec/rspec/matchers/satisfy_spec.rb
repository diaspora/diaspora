require 'spec_helper'

describe "should satisfy { block }" do
  it "describes itself" do
    satisfy.description.should eq("satisfy block")
  end

  it "passes if block returns true" do
    true.should satisfy { |val| val }
    true.should satisfy do |val|
      val
    end
  end

  it "fails if block returns false" do
    lambda {
      false.should satisfy { |val| val }
    }.should fail_with("expected false to satisfy block")
    lambda do
      false.should satisfy do |val|
        val
      end
    end.should fail_with("expected false to satisfy block")
  end
end

describe "should_not satisfy { block }" do
  it "passes if block returns false" do
    false.should_not satisfy { |val| val }
    false.should_not satisfy do |val|
      val
    end
  end

  it "fails if block returns true" do
    lambda {
      true.should_not satisfy { |val| val }
    }.should fail_with("expected true not to satisfy block")
  end
end
