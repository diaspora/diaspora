require "spec_helper"

describe "error_on" do
  it "provides a description including the name of what the error is on" do
    have(1).error_on(:whatever).description.should == "have 1 error on :whatever"
  end

  it "provides a failure message including the number actually given" do
    lambda {
      [].should have(1).error_on(:whatever)
    }.should raise_error("expected 1 error on :whatever, got 0")
  end
end

describe "errors_on" do
  it "provides a description including the name of what the error is on" do
    have(2).errors_on(:whatever).description.should == "have 2 errors on :whatever"
  end

  it "provides a failure message including the number actually given" do
    lambda {
      [1].should have(3).errors_on(:whatever)
    }.should raise_error("expected 3 errors on :whatever, got 1")
  end
end

describe "have something other than error_on or errors_on" do
  it "has a standard rspec failure message" do
    lambda {
      [1,2,3].should have(2).elements
    }.should raise_error("expected 2 elements, got 3")
  end

  it "has a standard rspec description" do
    have(2).elements.description.should == "have 2 elements"
  end
end

