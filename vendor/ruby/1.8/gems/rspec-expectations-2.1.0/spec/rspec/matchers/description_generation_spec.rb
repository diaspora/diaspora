require 'spec_helper'

describe "Matchers should be able to generate their own descriptions" do
  after(:each) do
    RSpec::Matchers.clear_generated_description
  end

  it "should == expected" do
    "this".should == "this"
    RSpec::Matchers.generated_description.should == "should == \"this\""
  end
  
  it "should not == expected" do
    "this".should_not == "that"
    RSpec::Matchers.generated_description.should == "should not == \"that\""
  end
  
  it "should be empty (arbitrary predicate)" do
    [].should be_empty
    RSpec::Matchers.generated_description.should == "should be empty"
  end
  
  it "should not be empty (arbitrary predicate)" do
    [1].should_not be_empty
    RSpec::Matchers.generated_description.should == "should not be empty"
  end
  
  it "should be true" do
    true.should be_true
    RSpec::Matchers.generated_description.should == "should be true"
  end
  
  it "should be false" do
    false.should be_false
    RSpec::Matchers.generated_description.should == "should be false"
  end
  
  it "should be nil" do
    nil.should be_nil
    RSpec::Matchers.generated_description.should == "should be nil"
  end
  
  it "should be > n" do
    5.should be > 3
    RSpec::Matchers.generated_description.should == "should be > 3"
  end
  
  it "should be predicate arg1, arg2 and arg3" do
    5.0.should be_between(0,10)
    RSpec::Matchers.generated_description.should == "should be between 0 and 10"
  end

  it "should equal" do
    expected = "expected"
    expected.should equal(expected)
    RSpec::Matchers.generated_description.should == "should equal \"expected\""
  end
  
  it "should_not equal" do
    5.should_not equal(37)
    RSpec::Matchers.generated_description.should == "should not equal 37"
  end
  
  it "should eql" do
    "string".should eql("string")
    RSpec::Matchers.generated_description.should == "should eql \"string\""
  end
  
  it "should not eql" do
    "a".should_not eql(:a)
    RSpec::Matchers.generated_description.should == "should not eql :a"
  end
  
  it "should have_key" do
    {:a => "a"}.should have_key(:a)
    RSpec::Matchers.generated_description.should == "should have key :a"
  end
  
  it "should have n items" do
    team.should have(3).players
    RSpec::Matchers.generated_description.should == "should have 3 players"
  end
  
  it "should have at least n items" do
    team.should have_at_least(2).players
    RSpec::Matchers.generated_description.should == "should have at least 2 players"
  end
  
  it "should have at most n items" do
    team.should have_at_most(4).players
    RSpec::Matchers.generated_description.should == "should have at most 4 players"
  end
  
  it "should include" do
    [1,2,3].should include(3)
    RSpec::Matchers.generated_description.should == "should include 3"
  end

  it "array.should =~ [1,2,3]" do
    [1,2,3].should =~ [1,2,3]
    RSpec::Matchers.generated_description.should == "should contain exactly 1, 2 and 3"
  end
  
  it "should match" do
    "this string".should match(/this string/)
    RSpec::Matchers.generated_description.should == "should match /this string/"
  end
  
  it "should raise_error" do
    lambda { raise }.should raise_error
    RSpec::Matchers.generated_description.should == "should raise Exception"
  end
  
  it "should raise_error with type" do
    lambda { raise }.should raise_error(RuntimeError)
    RSpec::Matchers.generated_description.should == "should raise RuntimeError"
  end
  
  it "should raise_error with type and message" do
    lambda { raise "there was an error" }.should raise_error(RuntimeError, "there was an error")
    RSpec::Matchers.generated_description.should == "should raise RuntimeError with \"there was an error\""
  end
  
  it "should respond_to" do
    [].should respond_to(:insert)
    RSpec::Matchers.generated_description.should == "should respond to #insert"
  end
  
  it "should throw symbol" do
    lambda { throw :what_a_mess }.should throw_symbol
    RSpec::Matchers.generated_description.should == "should throw a Symbol"
  end
  
  it "should throw symbol (with named symbol)" do
    lambda { throw :what_a_mess }.should throw_symbol(:what_a_mess)
    RSpec::Matchers.generated_description.should == "should throw :what_a_mess"
  end
  
  def team
    Class.new do
      def players
        [1,2,3]
      end
    end.new
  end
end

describe "a Matcher with no description" do
  def matcher
     Class.new do
       def matches?(ignore); true; end
       def failure_message; ""; end
     end.new
  end
  
  it "provides a helpful message when used in a string-less example block" do
    5.should matcher
    RSpec::Matchers.generated_description.should =~ /When you call.*description method/m
  end
end
