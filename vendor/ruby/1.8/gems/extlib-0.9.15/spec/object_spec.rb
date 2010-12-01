require 'spec_helper'
require 'extlib/object'

module HactiveSupport
  class MemoizeConsideredUseless
  end
end

class SymbolicDuck
  def quack
  end
end

class ClassyDuck
end

module Foo
  class Bar
  end
end

class Oi
  attr_accessor :foo
end

describe Object do

  describe "#full_const_get" do
    it 'returns constant by FQ name in receiver namespace' do
      Object.full_const_get("Oi").should == Oi
      Object.full_const_get("Foo::Bar").should == Foo::Bar
    end
  end

  describe "#full_const_set" do
    it 'sets constant value by FQ name in receiver namespace' do
      Object.full_const_set("HactiveSupport::MCU", HactiveSupport::MemoizeConsideredUseless)

      Object.full_const_get("HactiveSupport::MCU").should == HactiveSupport::MemoizeConsideredUseless
      HactiveSupport.full_const_get("MCU").should == HactiveSupport::MemoizeConsideredUseless
    end
  end

  describe "#make_module" do
    it 'creates a module from string FQ name' do
      Object.make_module("Milano")
      Object.make_module("Norway::Oslo")

      Object.const_defined?("Milano").should == true
      Norway.const_defined?("Oslo").should == true
    end

    it "handles the case where we already have a class in the heirarchy" do
      Object.make_module("Foo::Bar::Baz")
      Object.const_defined?("Foo").should == true
      Foo.const_defined?("Bar").should == true
      Foo::Bar.const_defined?("Baz").should == true
      Foo::Bar::Baz.should be_kind_of(Module)
    end
  end


  describe "#quacks_like?" do
    it 'returns true if duck is a Symbol and receiver responds to it' do
      SymbolicDuck.new.quacks_like?(:quack).should be_true
    end

    it 'returns false if duck is a Symbol and receiver DOES NOT respond to it' do
      SymbolicDuck.new.quacks_like?(:wtf).should be_false
    end

    it 'returns true if duck is a class and receiver is its instance' do
      receiver = ClassyDuck.new
      receiver.quacks_like?(ClassyDuck).should be_true
    end

    it 'returns false if duck is a class and receiver IS NOT its instance' do
      receiver = ClassyDuck.new
      receiver.quacks_like?(SymbolicDuck).should be_false
    end

    it 'returns true if duck is an array and at least one of its members quacks like this duck' do
      receiver = ClassyDuck.new
      ary      = [ClassyDuck, SymbolicDuck]

      receiver.quacks_like?(ary).should be_true
    end

    it 'returns false if duck is an array and none of its members quacks like this duck' do
      receiver = ClassyDuck.new
      ary      = [SymbolicDuck.new, SymbolicDuck]

      receiver.quacks_like?(ary).should be_false
    end
  end

  describe "#in?" do
    it 'returns true if object is included in collection' do
      @ary = [1, 2, 3]
      @set = Set.new([2, 3, 5])

      1.in?(@ary).should be_true
      2.in?(@ary).should be_true
      3.in?(@ary).should be_true
      4.in?(@ary).should be_false

      1.in?(@set).should be_false
      2.in?(@set).should be_true
      3.in?(@set).should be_true
      4.in?(@set).should be_false
      5.in?(@set).should be_true
    end
  end
end
