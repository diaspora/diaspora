require 'spec_helper'

describe "should ==" do
  
  it "delegates message to target" do
    subject = "apple"
    subject.should_receive(:==).with("apple").and_return(true)
    subject.should == "apple"
  end
  
  it "returns true on success" do
    subject = "apple"
    (subject.should == "apple").should be_true
  end
  
  it "fails when target.==(actual) returns false" do
    subject = "apple"
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: "orange"\n     got: "apple" (using ==)], "orange", "apple")
    subject.should == "orange"
  end
  
end

describe "unsupported operators", :if => RUBY_VERSION.to_f == 1.9 do
  it "raises an appropriate error for should != expected" do
    expect {
      "apple".should != "pear"
    }.to raise_error(/does not support `should != expected`.  Use `should_not == expected`/)
  end

  it "raises an appropriate error for should_not != expected" do
    expect {
      "apple".should_not != "pear"
    }.to raise_error(/does not support `should_not != expected`.  Use `should == expected`/)
  end

  it "raises an appropriate error for should !~ expected" do
    expect {
      "apple".should !~ /regex/
    }.to raise_error(/does not support `should !~ expected`.  Use `should_not =~ expected`/)
  end

  it "raises an appropriate error for should_not !~ expected" do
    expect {
      "apple".should_not !~ /regex/
    }.to raise_error(/does not support `should_not !~ expected`.  Use `should =~ expected`/)
  end
end

describe "should_not ==" do
  
  it "delegates message to target" do
    subject = "orange"
    subject.should_receive(:==).with("apple").and_return(false)
    subject.should_not == "apple"
  end
  
  it "returns true on success" do
    subject = "apple"
    (subject.should_not == "orange").should be_false
  end

  it "fails when target.==(actual) returns false" do
    subject = "apple"
    RSpec::Expectations.should_receive(:fail_with).with(%[expected not: == "apple"\n         got:    "apple"], "apple", "apple")
    subject.should_not == "apple"
  end
  
end

describe "should ===" do
  
  it "delegates message to target" do
    subject = "apple"
    subject.should_receive(:===).with("apple").and_return(true)
    subject.should === "apple"
  end
  
  it "fails when target.===(actual) returns false" do
    subject = "apple"
    subject.should_receive(:===).with("orange").and_return(false)
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: "orange"\n     got: "apple" (using ===)], "orange", "apple")
    subject.should === "orange"
  end
  
end

describe "should_not ===" do
  
  it "delegates message to target" do
    subject = "orange"
    subject.should_receive(:===).with("apple").and_return(false)
    subject.should_not === "apple"
  end
  
  it "fails when target.===(actual) returns false" do
    subject = "apple"
    subject.should_receive(:===).with("apple").and_return(true)
    RSpec::Expectations.should_receive(:fail_with).with(%[expected not: === "apple"\n         got:     "apple"], "apple", "apple")
    subject.should_not === "apple"
  end

end

describe "should =~" do
  
  it "delegates message to target" do
    subject = "foo"
    subject.should_receive(:=~).with(/oo/).and_return(true)
    subject.should =~ /oo/
  end
  
  it "fails when target.=~(actual) returns false" do
    subject = "fu"
    subject.should_receive(:=~).with(/oo/).and_return(false)
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: /oo/\n     got: "fu" (using =~)], /oo/, "fu")
    subject.should =~ /oo/
  end

end

describe "should_not =~" do
  
  it "delegates message to target" do
    subject = "fu"
    subject.should_receive(:=~).with(/oo/).and_return(false)
    subject.should_not =~ /oo/
  end
  
  it "fails when target.=~(actual) returns false" do
    subject = "foo"
    subject.should_receive(:=~).with(/oo/).and_return(true)
    RSpec::Expectations.should_receive(:fail_with).with(%[expected not: =~ /oo/\n         got:    "foo"], /oo/, "foo")
    subject.should_not =~ /oo/
  end

end

describe "should >" do
  
  it "passes if > passes" do
    4.should > 3
  end

  it "fails if > fails" do
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: > 5\n     got:   4], 5, 4)
    4.should > 5
  end

end

describe "should >=" do
  
  it "passes if >= passes" do
    4.should > 3
    4.should >= 4
  end

  it "fails if > fails" do
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: >= 5\n     got:    4], 5, 4)
    4.should >= 5
  end

end

describe "should <" do
  
  it "passes if < passes" do
    4.should < 5
  end

  it "fails if > fails" do
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: < 3\n     got:   4], 3, 4)
    4.should < 3
  end

end

describe "should <=" do
  
  it "passes if <= passes" do
    4.should <= 5
    4.should <= 4
  end

  it "fails if > fails" do
    RSpec::Expectations.should_receive(:fail_with).with(%[expected: <= 3\n     got:    4], 3, 4)
    4.should <= 3
  end

end

describe RSpec::Matchers::PositiveOperatorMatcher do

  it "works when the target has implemented #send" do
    o = Object.new
    def o.send(*args); raise "DOH! Library developers shouldn't use #send!" end
    lambda {
      o.should == o
    }.should_not raise_error
  end

end

describe RSpec::Matchers::NegativeOperatorMatcher do

  it "works when the target has implemented #send" do
    o = Object.new
    def o.send(*args); raise "DOH! Library developers shouldn't use #send!" end
    lambda {
      o.should_not == :foo
    }.should_not raise_error
  end

end
