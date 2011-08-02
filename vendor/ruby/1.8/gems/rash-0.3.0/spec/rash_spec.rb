require 'spec_helper'

describe Hashie::Rash do
  subject {
    Hashie::Rash.new({
      "varOne" => 1,
      "two" => 2,
      :three => 3,
      :varFour => 4,
      "fiveHumpHumps" => 5,
      :nested => {
        "NestedOne" => "One",
        :two => "two",
        "nested_three" => "three"
      },
      "nestedTwo" => {
        "nested_two" => 22,
        :nestedThree => 23
      },
      "spaced Key" => "When would this happen?",
      "trailing spaces " => "better safe than sorry"
    })
  }

  it { should be_a(Hashie::Mash) }

  it "should create a new rash where all the keys are underscored instead of camelcased" do
    subject.var_one.should == 1
    subject.two.should == 2
    subject.three.should == 3
    subject.var_four.should == 4
    subject.five_hump_humps.should == 5
    subject.nested.should be_a(Hashie::Rash)
    subject.nested.nested_one.should == "One"
    subject.nested.two.should == "two"
    subject.nested.nested_three.should == "three"
    subject.nested_two.should be_a(Hashie::Rash)
    subject.nested_two.nested_two.should == 22
    subject.nested_two.nested_three.should == 23
    subject.spaced_key.should == "When would this happen?"
    subject.trailing_spaces.should == "better safe than sorry"
  end

  it "should allow camelCased accessors" do
    subject.varOne.should == 1
    subject.varOne = "once"
    subject.varOne.should == "once"
    subject.var_one.should == "once"
  end

  it "should allow camelCased accessors on nested hashes" do
    subject.nested.nestedOne.should == "One"
    subject.nested.nestedOne = "once"
    subject.nested.nested_one.should == "once"
  end

  it "should merge well with a Mash" do
    subject.update Hashie::Mash.new(
      :nested => {:fourTimes => "a charm"},
      :nested3 => {:helloWorld => "hi"}
    )

    subject.nested.four_times.should == "a charm"
    subject.nested.fourTimes.should == "a charm"
    subject.nested3.hello_world.should == "hi"
    subject.nested3.helloWorld.should == "hi"
  end

  it "should allow initializing reader" do
    subject.nested3!.helloWorld = "hi"
    subject.nested3.hello_world.should == "hi"
  end

end
