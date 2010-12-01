require 'spec_helper'

describe "should have_sym(*args)" do
  it "passes if #has_sym?(*args) returns true" do
    {:a => "A"}.should have_key(:a)
  end

  it "fails if #has_sym?(*args) returns false" do
    lambda {
      {:b => "B"}.should have_key(:a)
    }.should fail_with("expected #has_key?(:a) to return true, got false")
  end

  it "fails if #has_sym?(*args) returns nil" do
    klass = Class.new do
      def has_foo?
      end
    end
    lambda {
      klass.new.should have_foo
    }.should fail_with("expected #has_foo?(nil) to return true, got false")
  end

  it "fails if target does not respond to #has_sym?" do
    lambda {
      Object.new.should have_key(:a)
    }.should raise_error(NoMethodError)
  end
  
  it "reraises an exception thrown in #has_sym?(*args)" do
    o = Object.new
    def o.has_sym?(*args)
      raise "Funky exception"
    end
    lambda { o.should have_sym(:foo) }.should raise_error("Funky exception")
  end
end

describe "should_not have_sym(*args)" do
  it "passes if #has_sym?(*args) returns false" do
    {:a => "A"}.should_not have_key(:b)
  end

  it "passes if #has_sym?(*args) returns nil" do
    klass = Class.new do
      def has_foo?
      end
    end
    klass.new.should_not have_foo
  end

  it "fails if #has_sym?(*args) returns true" do
    lambda {
      {:a => "A"}.should_not have_key(:a)
    }.should fail_with("expected #has_key?(:a) to return false, got true")
  end

  it "fails if target does not respond to #has_sym?" do
    lambda {
      Object.new.should have_key(:a)
    }.should raise_error(NoMethodError)
  end
  
  it "reraises an exception thrown in #has_sym?(*args)" do
    o = Object.new
    def o.has_sym?(*args)
      raise "Funky exception"
    end
    lambda { o.should_not have_sym(:foo) }.should raise_error("Funky exception")
  end
end

describe "has" do
  it "works when the target implements #send" do
    o = {:a => "A"}
    def o.send(*args); raise "DOH! Library developers shouldn't use #send!" end
    lambda {
      o.should have_key(:a)
    }.should_not raise_error
  end
end
