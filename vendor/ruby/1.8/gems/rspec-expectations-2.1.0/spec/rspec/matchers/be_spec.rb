require 'spec_helper'

describe "should be_predicate" do  
  it "allows other undefined methods to raise errors as normal" do
    expect { some_undefined_method }.to raise_error(NameError)
  end

  it "passes when actual returns true for :predicate?" do
    actual = stub("actual", :happy? => true)
    actual.should be_happy
  end

  it "passes when actual returns true for :predicates? (present tense)" do
    actual = stub("actual", :exists? => true, :exist? => true)
    actual.should be_exist
  end

  it "fails when actual returns false for :predicate?" do
    actual = stub("actual", :happy? => false)
    lambda {
      actual.should be_happy
    }.should fail_with("expected happy? to return true, got false")
  end
  
  it "fails when actual returns false for :predicate?" do
    actual = stub("actual", :happy? => nil)
    lambda {
      actual.should be_happy
    }.should fail_with("expected happy? to return true, got nil")
  end
  
  it "fails when actual does not respond to :predicate?" do
    lambda {
      Object.new.should be_happy
    }.should raise_error(NameError, /happy\?/)
  end
  
  it "fails on error other than NameError" do
    actual = stub("actual")
    actual.should_receive(:foo?).and_raise("aaaah")
    lambda {
      actual.should be_foo
    }.should raise_error(/aaaah/)
  end
  
  it "fails on error other than NameError (with the present tense predicate)" do
    actual = Object.new
    actual.should_receive(:foos?).and_raise("aaaah")
    lambda {
      actual.should be_foo
    }.should raise_error(/aaaah/)
  end
end

describe "should_not be_predicate" do
  it "passes when actual returns false for :sym?" do
    actual = stub("actual", :happy? => false)
    actual.should_not be_happy
  end
  
  it "passes when actual returns nil for :sym?" do
    actual = stub("actual", :happy? => nil)
    actual.should_not be_happy
  end
  
  it "fails when actual returns true for :sym?" do
    actual = stub("actual", :happy? => true)
    lambda {
      actual.should_not be_happy
    }.should fail_with("expected happy? to return false, got true")
  end

  it "fails when actual does not respond to :sym?" do
    lambda {
      Object.new.should_not be_happy
    }.should raise_error(NameError)
  end
end

describe "should be_predicate(*args)" do
  it "passes when actual returns true for :predicate?(*args)" do
    actual = mock("actual")
    actual.should_receive(:older_than?).with(3).and_return(true)
    actual.should be_older_than(3)
  end

  it "fails when actual returns false for :predicate?(*args)" do
    actual = mock("actual")
    actual.should_receive(:older_than?).with(3).and_return(false)
    lambda {
      actual.should be_older_than(3)
    }.should fail_with("expected older_than?(3) to return true, got false")
  end
  
  it "fails when actual does not respond to :predicate?" do
    lambda {
      Object.new.should be_older_than(3)
    }.should raise_error(NameError)
  end
end

describe "should_not be_predicate(*args)" do
  it "passes when actual returns false for :predicate?(*args)" do
    actual = mock("actual")
    actual.should_receive(:older_than?).with(3).and_return(false)
    actual.should_not be_older_than(3)
  end
  
  it "fails when actual returns true for :predicate?(*args)" do
    actual = mock("actual")
    actual.should_receive(:older_than?).with(3).and_return(true)
    lambda {
      actual.should_not be_older_than(3)
    }.should fail_with("expected older_than?(3) to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    lambda {
      Object.new.should_not be_older_than(3)
    }.should raise_error(NameError)
  end
end

describe "should be_predicate(&block)" do
  it "passes when actual returns true for :predicate?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:happy?).and_yield
    delegate.should_receive(:check_happy).and_return(true)
    actual.should be_happy { delegate.check_happy }
  end

  it "fails when actual returns false for :predicate?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:happy?).and_yield
    delegate.should_receive(:check_happy).and_return(false)
    lambda {
      actual.should be_happy { delegate.check_happy }
    }.should fail_with("expected happy? to return true, got false")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = mock("delegate", :check_happy => true)
    lambda {
      Object.new.should be_happy { delegate.check_happy }
    }.should raise_error(NameError)
  end
end

describe "should_not be_predicate(&block)" do
  it "passes when actual returns false for :predicate?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:happy?).and_yield
    delegate.should_receive(:check_happy).and_return(false)
    actual.should_not be_happy { delegate.check_happy }
  end

  it "fails when actual returns true for :predicate?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:happy?).and_yield
    delegate.should_receive(:check_happy).and_return(true)
    lambda {
      actual.should_not be_happy { delegate.check_happy }
    }.should fail_with("expected happy? to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = mock("delegate", :check_happy => true)
    lambda {
      Object.new.should_not be_happy { delegate.check_happy }
    }.should raise_error(NameError)
  end
end

describe "should be_predicate(*args, &block)" do
  it "passes when actual returns true for :predicate?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:older_than?).with(3).and_yield(3)
    delegate.should_receive(:check_older_than).with(3).and_return(true)
    actual.should be_older_than(3) { |age| delegate.check_older_than(age) }
  end

  it "fails when actual returns false for :predicate?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:older_than?).with(3).and_yield(3)
    delegate.should_receive(:check_older_than).with(3).and_return(false)
    lambda {
      actual.should be_older_than(3) { |age| delegate.check_older_than(age) }
    }.should fail_with("expected older_than?(3) to return true, got false")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = mock("delegate", :check_older_than => true)
    lambda {
      Object.new.should be_older_than(3) { |age| delegate.check_older_than(age) }
    }.should raise_error(NameError)
  end
end

describe "should_not be_predicate(*args, &block)" do
  it "passes when actual returns false for :predicate?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:older_than?).with(3).and_yield(3)
    delegate.should_receive(:check_older_than).with(3).and_return(false)
    actual.should_not be_older_than(3) { |age| delegate.check_older_than(age) }
  end

  it "fails when actual returns true for :predicate?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:older_than?).with(3).and_yield(3)
    delegate.should_receive(:check_older_than).with(3).and_return(true)
    lambda {
      actual.should_not be_older_than(3) { |age| delegate.check_older_than(age) }
    }.should fail_with("expected older_than?(3) to return false, got true")
  end

  it "fails when actual does not respond to :predicate?" do
    delegate = mock("delegate", :check_older_than => true)
    lambda {
      Object.new.should_not be_older_than(3) { |age| delegate.check_older_than(age) }
    }.should raise_error(NameError)
  end
end

describe "should be_true" do
  it "passes when actual equal?(true)" do
    true.should be_true
  end

  it "passes when actual is 1" do
    1.should be_true
  end

  it "fails when actual equal?(false)" do
    lambda {
      false.should be_true
    }.should fail_with("expected false to be true")
  end
end

describe "should be_false" do
  it "passes when actual equal?(false)" do
    false.should be_false
  end

  it "passes when actual equal?(nil)" do
    nil.should be_false
  end

  it "fails when actual equal?(true)" do
    lambda {
      true.should be_false
    }.should fail_with("expected true to be false")
  end
end

describe "should be_nil" do
  it "passes when actual is nil" do
    nil.should be_nil
  end

  it "fails when actual is not nil" do
    lambda {
      :not_nil.should be_nil
    }.should fail_with("expected nil, got :not_nil")
  end
end

describe "should_not be_nil" do
  it "passes when actual is not nil" do
    :not_nil.should_not be_nil
  end

  it "fails when actual is nil" do
    lambda {
      nil.should_not be_nil
    }.should fail_with("expected not nil, got nil")
  end
end

describe "should be <" do
  it "passes when < operator returns true" do
    3.should be < 4
  end

  it "fails when < operator returns false" do
    lambda { 3.should be < 3 }.should fail_with("expected < 3, got 3")
  end

  it "describes itself" do
    be.<(4).description.should == "be < 4"
  end
end

describe "should be <=" do
  it "passes when <= operator returns true" do
    3.should be <= 4
    4.should be <= 4
  end

  it "fails when <= operator returns false" do
    lambda { 3.should be <= 2 }.should fail_with("expected <= 2, got 3")
  end
end

describe "should be >=" do
  it "passes when >= operator returns true" do
    4.should be >= 4
    5.should be >= 4
  end

  it "fails when >= operator returns false" do
    lambda { 3.should be >= 4 }.should fail_with("expected >= 4, got 3")
  end
end

describe "should be >" do
  it "passes when > operator returns true" do
    5.should be > 4
  end

  it "fails when > operator returns false" do
    lambda { 3.should be > 4 }.should fail_with("expected > 4, got 3")
  end
end

describe "should be ==" do
  it "passes when == operator returns true" do
    5.should be == 5
  end

  it "fails when == operator returns false" do
    lambda { 3.should be == 4 }.should fail_with("expected == 4, got 3")
  end
end

describe "should be ===" do
  it "passes when === operator returns true" do
    Hash.should be === Hash.new
  end

  it "fails when === operator returns false" do
    lambda { Hash.should be === "not a hash" }.should fail_with(%[expected === not a hash, got Hash])
  end
end

describe "should_not with operators" do
  it "coaches user to stop using operators with should_not" do
    lambda {
      5.should_not be < 6
    }.should raise_error(/not only FAILED,\nit is a bit confusing./m)
  end
end

describe "should be" do
  it "passes if actual is truthy" do
    true.should be
    1.should be
  end

  it "fails if actual is false" do
    lambda {false.should be}.should fail_with("expected false to evaluate to true")
  end

  it "fails if actual is nil" do
    lambda {nil.should be}.should fail_with("expected nil to evaluate to true")
  end

  it "describes itself" do
    be.description.should == "be"
  end
end

describe "should_not be" do
  it "passes if actual is falsy" do
    false.should_not be
    nil.should_not be
  end

  it "fails on true" do
    lambda {true.should_not be}.should fail_with("expected true to evaluate to false")
  end
end

describe "should be(value)" do
  it "delegates to equal" do
    self.should_receive(:equal).with(5)
    5.should be(5)
  end
end

describe "should_not be(value)" do
  it "delegates to equal" do
    self.should_receive(:equal).with(4)
    5.should_not be(4)
  end
end

describe "'should be' with operator" do
  it "includes 'be' in the description" do
    (be > 6).description.should =~ /be > 6/
    (be >= 6).description.should =~ /be >= 6/
    (be <= 6).description.should =~ /be <= 6/
    (be < 6).description.should =~ /be < 6/
  end
end


describe "arbitrary predicate with DelegateClass" do
  it "accesses methods defined in the delegating class (LH[#48])" do
    require 'delegate'
    class ArrayDelegate < DelegateClass(Array)
      def initialize(array)
        @internal_array = array
        super(@internal_array)
      end

      def large?
        @internal_array.size >= 5
      end
    end

    delegate = ArrayDelegate.new([1,2,3,4,5,6])
    delegate.should be_large
  end
end

describe "be_a, be_an" do
  it "passes when class matches" do
    "foobar".should be_a(String)
    [1,2,3].should be_an(Array)
  end

  it "fails when class does not match" do
    "foobar".should_not be_a(Hash)
    [1,2,3].should_not be_an(Integer)
  end
end

describe "be_an_instance_of" do
  it "passes when direct class matches" do
    5.should be_an_instance_of(Fixnum)
  end
  
  it "fails when class is higher up hierarchy" do
    5.should_not be_an_instance_of(Numeric)
  end
end

