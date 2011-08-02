require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::MethodObject do
  before do 
    Registry.clear 
    @yard = ModuleObject.new(:root, :YARD)
  end
  
  it "should have a path of testing for an instance method in the root" do
    meth = MethodObject.new(:root, :testing)
    meth.path.should == "#testing"
  end
  
  it "should have a path of YARD#testing for an instance method in YARD" do
    meth = MethodObject.new(@yard, :testing)
    meth.path.should == "YARD#testing"
  end
  
  it "should have a path of YARD.testing for a class method in YARD" do
    meth = MethodObject.new(@yard, :testing, :class)
    meth.path.should == "YARD.testing"
  end
  
  it "should have a path of ::testing (note the ::) for a class method added to root namespace" do
    meth = MethodObject.new(:root, :testing, :class)
    meth.path.should == "::testing"
  end
  
  it "should exist in the registry after successful creation" do
    obj = MethodObject.new(@yard, :something, :class)
    Registry.at("YARD.something").should_not be_nil
    Registry.at("YARD#something").should be_nil
    Registry.at("YARD::something").should be_nil
    obj = MethodObject.new(@yard, :somethingelse)
    Registry.at("YARD#somethingelse").should_not be_nil
  end
  
  it "should allow #scope to be changed after creation" do
    obj = MethodObject.new(@yard, :something, :class)
    Registry.at("YARD.something").should_not be_nil
    obj.scope = :instance
    Registry.at("YARD.something").should be_nil
    Registry.at("YARD#something").should_not be_nil
  end
  
  describe '#name' do
    it "should show a prefix for an instance method when prefix=true" do
      obj = MethodObject.new(nil, :something)
      obj.name(true).should == "#something"
    end
    
    it "should never show a prefix for a class method" do
      obj = MethodObject.new(nil, :something, :class)
      obj.name.should == :"something"
      obj.name(true).should == "something"
    end
  end
  
  describe '#is_attribute?' do
    it "should only return true if attribute is set in namespace for read/write" do
      obj = MethodObject.new(@yard, :foo)
      @yard.attributes[:instance][:foo] = {:read => obj, :write => nil}
      obj.is_attribute?.should be_true
      MethodObject.new(@yard, :foo=).is_attribute?.should be_false
    end
  end
  
  describe '#attr_info' do
    it "should return attribute info if namespace is available" do
      obj = MethodObject.new(@yard, :foo)
      @yard.attributes[:instance][:foo] = {:read => obj, :write => nil}
      obj.attr_info.should == @yard.attributes[:instance][:foo]
    end
    
    it "should return nil if namespace is proxy" do
      obj = MethodObject.new(P(:ProxyClass), :foo)
      MethodObject.new(@yard, :foo).attr_info.should == nil
    end
    
    it "should return nil if meth is not an attribute" do
      MethodObject.new(@yard, :notanattribute).attr_info.should == nil
    end
  end
  
  describe '#writer?' do
    it "should return true if method is a writer attribute" do
      obj = MethodObject.new(@yard, :foo=)
      @yard.attributes[:instance][:foo] = {:read => nil, :write => obj}
      obj.writer?.should == true
      MethodObject.new(@yard, :NOTfoo=).writer?.should == false
    end
  end

  describe '#reader?' do
    it "should return true if method is a reader attribute" do
      obj = MethodObject.new(@yard, :foo)
      @yard.attributes[:instance][:foo] = {:read => obj, :write => nil}
      obj.reader?.should == true
      MethodObject.new(@yard, :NOTfoo).reader?.should == false
    end
  end
  
  describe '#constructor?' do
    before { @class = ClassObject.new(:root, :MyClass) }

    it "should mark the #initialize method as constructor" do
      MethodObject.new(@class, :initialize)
    end
    
    it "should not mark Klass.initialize as constructor" do
      MethodObject.new(@class, :initialize, :class).constructor?.should be_false
    end
    
    it "should not mark module method #initialize as constructor" do
      MethodObject.new(@yard, :initialize).constructor?.should be_false
    end
  end
  
  describe '#overridden_method' do
    before { Registry.clear }
    
    it "should return overridden method from mixin first" do
      YARD.parse_string(<<-eof)
        module C; def foo; end end
        class A; def foo; end end
        class B < A; include C; def foo; end end
      eof
      Registry.at('B#foo').overridden_method.should == Registry.at('C#foo')
    end
    
    it "should return overridden method from superclass" do
      YARD.parse_string(<<-eof)
        class A; def foo; end end
        class B < A; def foo; end end
      eof
      Registry.at('B#foo').overridden_method.should == Registry.at('A#foo')
    end
    
    it "should return nil if none is found" do
      YARD.parse_string(<<-eof)
        class A; end
        class B < A; def foo; end end
      eof
      Registry.at('B#foo').overridden_method.should be_nil
    end
    
    it "should return nil if namespace is a proxy" do
      YARD.parse_string "def ARGV.foo; end"
      Registry.at('ARGV.foo').overridden_method.should be_nil
    end
  end
end
